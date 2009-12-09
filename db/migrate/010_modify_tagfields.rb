class ModifyTagfields < ActiveRecord::Migration
  def self.up
    add_column :tags, :is_category, :boolean, :default => false
    add_column :tags, :description, :string, :default => false
    
      [
        ["Language-and-Literature", "Rhetoric/Writing, Literature, Linguistics, Foreign Languages"],
        ["Business-and-Economics", "Accounting, Finance, Management, Marketing, Economics"],
        ["Math","Architecture, Engineering, Mathematics, Statistics"],
        ["Science", "Biology, Chemistry, Astronomy, Computer Sciences, Physics, Pharmacy, Nursing, Management Information Systems, Kinesiology, Geology, Geography"],
        ["Social-and-Behavioral-Sciences","Anthropology, Law, Criminal Justice, Cultural Studies , Government, History, Sociology, Social Work, Education, Philosophy, Psychology, Religion"],
        ["Communications-and-Arts","Advertising, Public Relations, Radio/Television/Film, Journalism, Art/Art History, Music, Theatre/Dance, Performance Arts"],
        ["Evaluation-Testing","LSAT, GRE, MCAT, DAT, PSAT"]
    ].each do |category|
        Tag.create(:name => category[0], :description => category[1], :is_category => true)
      end
  end

  def self.down
    remove_column :tags, :is_category
    remove_column :tags, :description
  end
end
