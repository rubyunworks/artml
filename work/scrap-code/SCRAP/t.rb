
module Test

  def tt
    puts 4
  end

  def tt_<<
    put 6
  end

end


a = [1,2,3]

a.extend Test

a.tt
a.tt_<<
