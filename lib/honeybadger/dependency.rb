module Honeybadger
  class Dependency
    class << self
      @@dependencies = []

      def register
        @@dependencies << new.tap { |d| d.instance_eval(&Proc.new) }
      end

      def inject!
        @@dependencies.each do |dependency|
          dependency.inject! if dependency.ok?
        end
      end
    end

    def initialize
      @injected     = false
      @requirements = []
      @injections   = []
    end

    def requirement
      @requirements << Proc.new
    end

    def injection
      @injections << Proc.new
    end

    def ok?
      @requirements.all?(&:call)
    rescue => e
      Honeybadger.write_verbose_log("Exception caught while verifying dependency: #{e.class} -- #{e.message}", :error)
      false
    end

    def inject!
      unless @injected
        @injections.each(&:call)
      end
    rescue => e
      Honeybadger.write_verbose_log("Exception caught while injecting dependency: #{e.class} -- #{e.message}", :error)
      false
    ensure
      @injected = true
    end
  end
end
