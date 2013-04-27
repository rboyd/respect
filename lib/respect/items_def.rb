module Respect
  class ItemsDef < BaseDef
    include DefWithoutName

    def initialize
      @items = []
    end

    private

    def evaluation_result
      @items
    end

    def update_result(name, schema)
      @items << schema
      schema
    end
  end
end