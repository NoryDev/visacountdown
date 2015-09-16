class Countdown

  def initialize(destination: nil)
    @destination = destination
  end

  def time_spent
    # @destination.reload
    get_time_spent(Date.current, @destination.latest_entry)
  end

  def remaining_time
    # @destination.reload
    get_remaining_time(Date.current, @destination.latest_entry)
  end

  def exit_day
  end

  def next_entry
  end

  # def next_entry(date = Date.current)
  #   wt = 0
  #   (date..(date + 90)).each do |day|
  #     wt += 1 if get_time_spent(day, true) >= 90
  #   end
  #   date + wt
  # end

  private

    def can_enter
    end

    def entry_has_happened?(date = Date.current, latest_entry = nil)
      if latest_entry
        latest_entry < date
      else
        nil
      end
    end

    def get_time_spent(date = Date.current, latest_entry = nil)
      nb_days = 0

      oldest_date = date - 179
      user_periods = @destination.periods.clone

      user_periods = remove_too_old(user_periods, oldest_date)
      user_periods = remove_future(user_periods, date)

      user_periods = remove_overlaps(user_periods, latest_entry) if latest_entry

      if user_periods.present?
        user_periods = user_periods.map do |period|
          (period.last_day - period.first_day).to_i + 1
        end
        nb_days += user_periods.reduce(:+)
      end

      if latest_entry && entry_has_happened?(date, latest_entry)
        nb_days += (date - latest_entry).to_i + 1
      end
      nb_days
    end

    def get_remaining_time(date = Date.current, latest_entry = nil)
      rt = 0

      if latest_entry
        # start after entry, who is in the past
        (date..(latest_entry + 89)).each do |day|
          rt += 1 if get_time_spent(day + 1, latest_entry) <= 90
        end
      else
        (date..(date + 89)).each do |day|
          rt += 1 if get_time_spent(day + 1) + rt <= 90
        end
        rt -= 1
      end
      rt
    end

    def remove_too_old(periods, oldest_date)
      # remove if period is entirely before oldest date
      periods = periods.reject do |p|
        (p.last_day - oldest_date).to_i < 0
      end

      # remove all the days that are before the oldest day
      periods.map do |p|
        p.first_day = oldest_date if (p.first_day - oldest_date).to_i < 0
        p
      end
    end

    def remove_future(periods, day)
      # remove period if it is totally in the future
      periods = periods.reject do |p|
        (p.first_day - day).to_i > 0
      end

      # remove days of the period that are in the future
      periods.map do |p|
        p.last_day = day if (p.last_day - day).to_i > 0
        p
      end
    end

    def remove_overlaps(periods, latest_entry)
      # remove period if started after latest entry
      periods = periods.reject do |p|
        (latest_entry - p.first_day).to_i <= 0
      end

      # remove days that are after latest entry
      periods.map do |p|
        p.last_day = (latest_entry - 1) if (latest_entry - p.last_day).to_i <= 0
        p
      end
    end
end