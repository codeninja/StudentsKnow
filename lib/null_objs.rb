class NullPage
  def zone(*args)
    return NullZone.new
  end
end

class NullZone
  def get(*args)
    return NullAd.new
  end
end

class NullAd
  def code(*args)
    return ""
  end
end