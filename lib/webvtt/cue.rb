module WebVTT
  class Cue
    attr_accessor :identifier, :start, :end, :style, :text, :annotations, :content

    TIMESTAMP_SEPARATOR = '-->'

    def initialize(cue = nil)
      @content = cue
      @style = {}
    end

    def self.parse(cue)
      cue = Cue.new(cue)
      cue.parse
      return cue
    end

    def to_webvtt
      res = ""
      if @identifier
        res << "#{@identifier}\n"
      end
      res << "#{@start} #{TIMESTAMP_SEPARATOR} #{@end} #{@style.map{|k,v| "#{k}:#{v}"}.join(" ")}".strip + "\n"
      res << @text

      res
    end

    def self.timestamp_in_sec(timestamp)
      mres = timestamp.match(/([0-9]{2}):([0-9]{2}):([0-9]{2}\.[0-9]{3})/)
      sec = mres[3].to_f # seconds and subseconds
      sec += mres[2].to_f * 60 # minutes
      sec += mres[1].to_f * 60 * 60 # hours
      return sec
    end

    def start_in_sec
      @start.to_f
    end

    def end_in_sec
      @end.to_f
    end

    def length
      @end.to_f - @start.to_f
    end

    def offset_by( offset_secs )
      @start += offset_secs
      @end   += offset_secs
    end

    def parse
      lines = @content.split("\n").map(&:strip)

      # it's a note, ignore
      return if lines[0] =~ /NOTE/

      validate_timestamp

      if !lines[0].include?(TIMESTAMP_SEPARATOR)
        @identifier = lines[0]
        lines.shift
      end

      if lines.empty?
        return
      end

      if lines[0].match(/(([0-9]{2}:)?[0-9]{2}:[0-9]{2}\.[0-9]{3}) -+> (([0-9]{2}:)?[0-9]{2}:[0-9]{2}\.[0-9]{3})(.*)/)
        @start = Timestamp.new $1
        @end = Timestamp.new $3
        @style = Hash[$5.strip.split(" ").map{|s| s.split(":").map(&:strip) }]
      elsif lines[0].match(/([0-9]{2}:[0-9]{2}\.[0-9]{3}) -+> ([0-9]{2}:[0-9]{2}\.[0-9]{3})(.*)/)
        @start = Timestamp.new '00:'+ $1
        @end = Timestamp.new '00:'+ $2
        @style = Hash[$3.strip.split(" ").map{|s| s.split(":").map(&:strip) }]
      end

      @text = lines[1..-1].join("\n")
    end

    def validate_timestamp
      return true if @content.include?(TIMESTAMP_SEPARATOR)

      raise MissingTimestamp, 'Time is missing against some of the index points.'
    end
  end
end
