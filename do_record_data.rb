Dir.chdir '/home/pi/air_data'

# will do 18Kb writes into different files instead of lots of 100b writes possibly into the same file
# (so I guess it will kill the next SD-card in 200 days instead of one day)
# (actually with different files it should be not so bad)

Entry = Struct.new :file, :value

loop do
  entry = {}

  time = Time.now
  file = time.strftime '%Y-%m-%d--%H.csv'
  at = time.to_i

  # hardcoded values 50 - humidity, 5 - pause between calls I assume
  got = `sudo /home/pi/sensor/src/sds -q -l 1 -w 5 -H 50`

  # PM 2.5 0.841080, PM10 1.400000
  got = got.lines.find { |x| x =~ /PM10/ }.strip.split(/[\s,]+/)

  entry_str = [time.to_i.to_s, got[2], got[4]] * ?,
  entry = Entry.new file, entry_str

  record entry
  sleep 5
end

BEGIN {
  $buffer = {}

  def record entry
    if !$buffer[entry.file]
      # flushing buffer first
      $buffer.each_pair { |file, entries|
        text = entries.map(&:value).join ?\n
        File.write file, text
      }
      $buffer = {}
    end

    # adding to the buffer
    $buffer[entry.file] ||= []
    $buffer[entry.file] << entry
  end
}
