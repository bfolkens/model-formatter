ActiveRecord::Schema.define do
  create_table :entries, :force => true do |t|
		t.column :some_integer, :integer
		t.column :some_boolean, :boolean
    t.column :sales_tax, :float
    t.column :area, :float
		t.column :complex_field, :string
		t.column :phone, :string
  end
end
