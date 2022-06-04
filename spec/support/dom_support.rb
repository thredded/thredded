# frozen_string_literal: true

RSpec.configure do
  def dom_class(record_or_class)
    ActionView::RecordIdentifier.dom_class(record_or_class)
  end

  def dom_id(record)
    ActionView::RecordIdentifier.dom_id(record)
  end

  def dom_id_as_selector(record)
    "##{dom_id(record)}"
  end
end
