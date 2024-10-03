class BaseRepository
  attr_reader :model

  def initialize(model)
    @model = model
  end

  def create!(data = {})
    @model.create!(data)
  end

  def find_by_id!(id)
    @model.find(id)
  end

  def update!(id, data)
    @model.lock.find(id).update!(data)
  end

  def delete(id)
    find_by_id!(id).destroy!
  end
end
