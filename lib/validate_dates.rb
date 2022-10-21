def check_dates_within_availability_range?(start_date, end_date, available_from, available_to)
  if (start_date > available_from) && (end_date < available_to)
    return true
  else
    return false
  end
end