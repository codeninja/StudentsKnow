ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(
  :date_time12  => "%m/%d/%Y %I:%M%p",
  :date_time24  => "%m/%d/%Y %H:%M",
  :date_only    => "%b. %d",
  :date_time12_only => "&nbsp;%I:%M%p",
  :date_time24_only => "%I:%M"
)