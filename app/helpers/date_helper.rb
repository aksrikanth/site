module DateHelper

  DAY_IN_SECOND  = 24 * 60 * 60
  WEEK_IN_SECOND = 7 * DAY_IN_SECOND

  def relative_time(event)
    delta_in_seconds = event - Time.now
    if delta_in_seconds < 0
      noun, count = human_readable_time_period(-delta_in_seconds)
      "#{pluralize(count, noun)} ago"
    else
      noun, count = human_readable_time_period(delta_in_seconds)
      "in #{pluralize(count, noun)}"
    end
  end

protected

  def human_readable_time_period(period)
    human_readable_period_in_years(period) or
      human_readable_period_in_months(period) or
      human_readable_period_in_weeks(period) or
      human_readable_period_in_days(period) or
      human_readable_period_in_hours(period) or
      human_readable_period_in_minutes(period) or
      human_readable_period_in_second(period)
  end

  def human_readable_period_in_years(period)
    present_period(period, 365 * DAY_IN_SECOND, 'year')
  end

  def human_readable_period_in_months(period)
    present_period(period, 30 * DAY_IN_SECOND, 'month')
  end

  def human_readable_period_in_weeks(period)
    present_period(period, 7 * DAY_IN_SECOND, 'week')
  end

  def human_readable_period_in_days(period)
    present_period(period, DAY_IN_SECOND, 'day')
  end

  def human_readable_period_in_hours(period)
    present_period(period, 60 * 60, 'hour')
  end

  def human_readable_period_in_minutes(period)
    present_period(period, 60, 'minute')
  end

  def human_readable_period_in_second(period)
    present_period(period, 1, 'second') || ['second', 1]
  end

  def present_period(period, divider, noun)
    value = period / divider
    return if value < 1
    value = value.round.to_i
    [noun, value]
  end

end
