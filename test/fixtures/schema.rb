ActiveRecord::Schema.define do
  create_table :entries, :force => true do |t|
		t.column :some_integer, :integer
		t.column :some_boolean, :boolean
    t.column :sales_tax, :integer
    t.column :super_precise_tax, :integer
    t.column :area, :float
		t.column :complex_field, :string
		t.column :phone, :integer
  end
end
