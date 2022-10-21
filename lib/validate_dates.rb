def check_dates_within_availability_range?(start_date, end_date, available_from, available_to)
  start_date_object = Date.parse(start_date) 
  end_date_object = Date.parse(end_date) 
  available_from_object = Date.parse(available_from)
  available_to_object = Date.parse(available_to)
  if (start_date_object < end_date_object) && 
      (start_date_object > available_from_object) && 
      (end_date_object < available_to_object)
    return true
  else
    return false
  end
end
