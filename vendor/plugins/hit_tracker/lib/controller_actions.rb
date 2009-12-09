module Controller
  module Hit
    def hit(object, kind = 'PageView')
      if object.kind_of?(Array)
        object.each do |item|
          item.hits.create(:kind => kind)
        end
      else
        object.hits.create(:kind => kind)
      end
    end
  end
end
