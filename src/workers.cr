module ClusterOfWorkers
  struct Worker
    def initialize(@pid : Int32, @master : Int32)
      # ....
    end

    def call(port)
      yield port
    end

    def kill
      Process.kill(Signal::KILL, @pid)
    end
  end

  class Cluster
    def initialize(@n : Int32)
      @master = Process.pid
      @workers = [] of Worker
    end

    def start(kemal, port)
      @n.times do |i|
        fork do
          worker = Worker.new(Process.pid, @master)
          @workers << worker

          worker.call(port) do |port|
            kemal.run do |config|
              server = config.server.not_nil!
              server.bind_tcp "0.0.0.0", port, reuse_port: true
            end
          end
        end
      end
      loop { }
    ensure
      stop
    end

    private def stop
      @workers.each(&.kill)
    end
  end
end
