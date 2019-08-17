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

    # (see ::Logger#debug)
    def debug(progname, &block)
      super unless @ignores[progname] >= LEVELS[:debug]
    end

    # (see ::Logger#info)
    def info(progname, &block)
      super unless @ignores[progname] >= LEVELS[:info]
    end

    # (see ::Logger#warn)
    def warn(progname, &block)
      super unless @ignores[progname] >= LEVELS[:warn]
    end

    # (see ::Logger#error)
    def error(progname, &block)
      super unless @ignores[progname] >= LEVELS[:error]
    end

    # (see ::Logger#fatal)
    def fatal(progname, &block)
      super unless @ignores[progname] >= LEVELS[:fatal]
    end

    # (see ::Logger#unknown)
    def unknown(progname, &block)
      super unless @ignores[progname] >= LEVELS[:unknown]
    end
  end
end
