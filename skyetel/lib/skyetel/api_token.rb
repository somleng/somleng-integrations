APIToken = Struct.new(:token, :retrieved_at, keyword_init: true) do
  def expired?
    retrieved_at < Time.now - (5 * 60)
  end
end
