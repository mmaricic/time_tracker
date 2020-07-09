module CustomTypes
  class PosInt
    def self.valid?(value)
      value.is_a?(Integer) && value >= 0
    end
  end

  class Initials
    def self.valid?(value)
      value.is_a?(String) && /^[A-Z]{2}$/.match?(value)
    end
  end

  class DateString
    def self.valid?(value)
      begin
        Date.parse(value)
        true
      rescue ArgumentError
        false
      end
    end
  end

  class CollectionOf < Contracts::CallableClass
    def initialize(item_contract)
      @item_contract = item_contract
    end
    
    def valid?(collection)
      collection.all? { |item| Contract.valid?(item, item_contract) }
    end

    private
    attr_reader :item_contract
  end

  class ActiveRecordRelationOf < Contracts::CallableClass
      def initialize(item_contract)
        @item_contract = item_contract
      end
  
      def valid?(value)
        return false unless value.is_a?(ActiveRecord::Relation)
        value.all? { |item| Contract.valid?(item, item_contract) }
      end
  
      private
      attr_reader :item_contract
    end
end