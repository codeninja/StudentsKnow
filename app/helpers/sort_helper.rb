module SortHelper
  # Create a link ('a' tag) back to the current action, but sorting by
  # _sort_column_ before any existing ordering.
  #
  # Example:
  # On an un-sorted page,
  #  <%= link_to_sort_by 'First Name', 'name' %>
  #  <%= link_to_sort_by 'Surname', 'family.name' %>
  #  <%= link_to_sort_by 'Email', 'email' %>
  # could result in:
  #  <a href="/person/list?sort=1">First Name</a>
  #  <a href="/person/list?sort=2">Surname</a>
  #  <a href="/person/list?sort=3">Email</a>
  #
  # If the page was already sorted by first name,
  #  <%= link_to_sort_by 'First Name', 'name' %>
  #  <%= link_to_sort_by 'Surname', 'family.name' %>
  #  <%= link_to_sort_by 'Email', 'email' %>
  # could result in:
  #  <a href="/person/list?sort=-1">First Name</a>
  #  <a href="/person/list?sort=2+1">Surname</a>
  #  <a href="/person/list?sort=3+1">Email</a>
  #
  def link_to_sort_by(link_text, sort_column)
    puts @@sort_keys.inspect
    sort_key = @@sort_keys[sort_column]
    return link_text unless sort_key
    
    sort = (params['sort'] || '').split.map {|param| param.to_i }
    
    if sort[0] && sort[0].abs == sort_key
      sort[0] = -sort[0]
    else
      sort.delete_if {|key| key.abs == sort_key }
      sort.unshift sort_key
    end
    
    link_to link_text, :params => {'sort' => sort.join(' ')}
  end
  
  # Set the columns that may be used to sort by.
  # You must set this from the controller before you can use
  # +link_to_sort_by+ in a view.
  #
  def self.columns=(column_names)
    # prepend id so that the first sortable column is at index 1
    @@sort_columns = ['id'] + column_names
    @@sort_keys = {}
    @@sort_columns.each_with_index {|obj, i| @@sort_keys[obj] = i }
  end
  
  # Set the columns that are used to sort by default
  #
  def self.default_order=(column_names)
    @@default_columns = column_names.map {|column| @@sort_keys[column] }
  end
  
  # This is a comparison method that returns -1, 0 or 1
  # depending on the passed objects _a_ and _b_, and the sorting
  # priorities defined in _params_. It can be used in blocks
  # given to +Enumerable#sort+.
  #
  # Use it like this:
  #  @people = Person.find_all.sort do |a, b|
  #    SortHelper.sort(a, b, params)
  #  end
  #
  def self.sort(a, b, params)
    if /\d/ === params['sort']
      params['sort'].split
    else
      @@default_columns
    end.each do |column_index|
      column_index = column_index.to_i
      next if column_index.abs >= @@sort_columns.size
      a_col = a
      b_col = b
      @@sort_columns[column_index.abs].split('.').each do |meth|
        a_col = a_col.send(meth)
        b_col = b_col.send(meth)
      end
      reverse = (column_index < 0)
      case a_col && a_col <=> b_col
      when -1
        return reverse ? 1 : -1
      when 1, nil  # nil < anything else
        return reverse ? -1 : 1
      end
    end
    0
  end

end

