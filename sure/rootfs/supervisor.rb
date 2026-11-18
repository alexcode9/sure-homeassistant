module SureHA
  class Supervisor
    def initialize(grace: 65)
      @children = {}
      @stopping = false
      @grace = grace
      %w[TERM INT].each { |signal| Signal.trap(signal) { @stopping = true } }
    end

    def stopping?; @stopping; end

    def start(name, *command)
      pid = Process.spawn(*command, pgroup: true)
      @children[pid] = name
      pid
    end

    def run_once(name, timeout, *command)
      pid = start(name, *command)
      deadline = monotonic + timeout
      loop do
        result = Process.waitpid2(pid, Process::WNOHANG)
        if result
          @children.delete(pid)
          return result[1].success?
        end
        return false if @stopping || monotonic >= deadline
        sleep 0.2
      end
    end

    def monitor
      until @stopping
        @children.keys.each do |pid|
          result = Process.waitpid2(pid, Process::WNOHANG)
          next unless result
          name = @children.delete(pid)
          warn "sure-ha: #{name} exited; stopping app for Supervisor recovery"
          return 1
        end
        sleep 0.2
      end
      0
    end

    def shutdown
      # Quiet Sidekiq before TERM so it stops accepting jobs immediately.
      @children.each { |pid, name| signal('TSTP', pid) if name == 'sidekiq' }
      @children.each_key { |pid| signal('TERM', pid) }
      deadline = monotonic + @grace
      until @children.empty? || monotonic >= deadline
        @children.keys.each do |pid|
          begin
            @children.delete(pid) if Process.waitpid(pid, Process::WNOHANG)
          rescue Errno::ECHILD
            @children.delete(pid)
          end
        end
        sleep 0.1
      end
      @children.each_key { |pid| signal('KILL', pid) }
      @children.each_key { |pid| Process.waitpid(pid) rescue Errno::ECHILD }
      @children.clear
    end

    private

    def monotonic; Process.clock_gettime(Process::CLOCK_MONOTONIC); end
    def signal(sig, pid)
      Process.kill(sig, -pid)
    rescue Errno::ESRCH
      nil
    end
  end
end
