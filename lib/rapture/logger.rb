# frozen_string_literal: true

module Rapture

  # A custom logger that allows for unsubscribing from
  # log feeds.
  class Logger < Logger
    # Level severity map
    LEVELS = {
      none: -1,
      debug: 0,
      info: 1,
      warn: 2,
      error: 3,
      fatal: 4,
      unknown: 5,
      all: 6,
    }

    # @!visibility false
    def initialize(io)
      @ignores = Hash.new(-1)
      super
    end

    # Unsubscribe from a feed, ignoring logs of `level` and below
    def ignore(progname, level = :info)
      @ignores[progname] = LEVELS[level.downcase]
    end

    # Log a message at the DEBUG level
    def debug(progname, &block)
      super unless @ignores[progname] >= LEVELS[:debug]
    end

    # Log a message at the INFO level
    def info(progname, &block)
      super unless @ignores[progname] >= LEVELS[:info]
    end

    # Log a message at the WARN level
    def warn(progname, &block)
      super unless @ignores[progname] >= LEVELS[:warn]
    end

    # Log a message at the ERROR level
    def error(progname, &block)
      super unless @ignores[progname] >= LEVELS[:error]
    end

    # Log a message at the FATAL level
    def fatal(progname, &block)
      super unless @ignores[progname] >= LEVELS[:fatal]
    end

    # Log a message at the UNKNOWN level
    def unknown(progname, &block)
      super unless @ignores[progname] >= LEVELS[:unknown]
    end
  end
end
