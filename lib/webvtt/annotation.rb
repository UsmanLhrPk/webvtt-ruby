module WebVTT
  class Annotation
    attr_reader :references, :annotations, :text, :title, :creator, :date

    ANNOTATION_REGEX = %r(/<c\.\d+>.*<\/c>/).freeze
    METADATA_REGEX = %r(/(?<=NOTE\nANNOTATIONS BEGIN\n)(.+)(?=\n\n)/).freeze
    REFERENCES_REGEX = %r(/(?<=NOTE\nANNOTATIONS BEGIN\n)(.+)(?=\n\n)/).freeze

    def initialize(content)
      parse_metadata(content)
      @references = parse_references(content)
      @annotations = []
    end

    def parse_metadata(content)
      content.match(REFERENCES_REGEX).split("\n").each do |data|
        data = data.split(/:\s*/)

        case data[0].downcase
        when 'annotation set title'
          @title = data[1]
        when 'annotation set creator'
          @creator = data[1]
        when 'annotation set date'
          @date = data[1]
        end
      end
    end

    def parse_references(content)
      content.match(REFERENCES_REGEX)
    end

    def parse(text)
      @text = text

      annotations = @text.match(ANNOTATION_REGEX)
      return [sanitize(@text), @annotations] unless annotations.present?

      @annotations = annotations.map { |annotation| annotation_hash(annotation) }
      [sanitize(@text), @annotations]
    end

    def annotation_hash(annotation)
      target = sanitize(annotation)
      start_index = @text.index(annotation)
      end_index = start_index + target.count

      { target: target, start: start_index, end: end_index }
    end

    def sanitize(text)
      text.gsub(/(<c\.\d+>|<\/c>)/, '')
    end
  end
end
