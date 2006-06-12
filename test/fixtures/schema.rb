ActiveRecord::Schema.define do
  create_table :entries, :force => true do |t|
    t.column :sales_tax, :float
    t.column :area, :float
		t.column :phone, :string
  end
end
