module WebVTT
  class Annotation
    attr_reader :references, :annotations, :text

    REGEX = /<c\.\d+>.*<\/c>/

    def initialize(content)
      @references = parse_references(content)
      @annotations = []
    end

    def parse_references(content)

    def parse(text)
      @text = text

      annotations = @text.match(REGEX)
      return [sanitize(@text), @annotations] unless annotations.present?

      @annotations = annotations.map { |annotation| annotation_hash(annotation) }
      [sanitize(@text), @annotations]
    end

    def annotation_hash(annotation)
      target = sanitize(annotation)
      start_index = @text.index(annotation)
      end_index = start_index + target.count

      { target: target, start: start_index  end: end_index, annotation:  }
    end

    def sanitize(text)
      text.gsub(/(<c\.\d+>|<\/c>)/, '')
    end
  end
end
