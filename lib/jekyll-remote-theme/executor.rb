require "open3"

module Jekyll
  module RemoteTheme
    module Executor
      class ExecutionError < StandardError; end

      TIMEOUT = 3600
      TIMEOUT_COMMANDS = %w(timeout gtimeout).freeze

      def run_command(*cmds)
        stdout, stderr, status = Open3.capture3(*cmds)

        if status.exitstatus != 0
          Jekyll.logger.error LOG_KEY, "Error running command #{cmds.join(" ")}"
          Jekyll.logger.debug LOG_KEY, stdout
          raise ExecutionError, stderr
        end

        stdout
      end

      def timeout_command
        cmd = TIMEOUT_COMMANDS.find { |exe| executable_exists?(exe) }
        cmd ? [cmd, TIMEOUT.to_s].freeze : [].freeze
      end

      private

      def executable_exists?(executable)
        ENV["PATH"].split(File::PATH_SEPARATOR).any? do |dir|
          exe = File.join(dir, executable)
          File.executable?(exe) && !File.directory?(exe)
        end
      end
    end
  end
end