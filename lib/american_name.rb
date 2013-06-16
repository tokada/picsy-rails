class AmericanName
  MALE_NAMES = %w[
    james john robert michael william david richard charles joseph
    thomas christopher daniel paul mark donald george kenneth steven
    edward brian ronald anthony kevin jason matthew gary timothy
    jose larry jeffrey frank scott eric stephen andrew raymond
    gregory joshua jerry dennis walter patrick peter harold douglas
    henry carl arthur ryan roger joe juan jack albert
    jonathan justin terry gerald keith samuel willie ralph lawrence
    nicholas roy benjamin bruce brandon adam harry fred wayne
    billy steve louis jeremy aaron randy howard eugene carlos
    russell bobby victor martin ernest phillip todd jesse craig
    alan shawn clarence sean philip chris johnny earl jimmy
    antonio danny bryan tony luis mike stanley leonard nathan
  ]
  FEMALE_NAMES = %w[
    mary patricia linda barbara elizabeth jennifer maria susan margaret
    dorothy lisa nancy karen betty helen sandra donna carol
    ruth sharon michelle laura sarah kimberly deborah jessica shirley
    cynthia angela melissa brenda amy anna rebecca virginia kathleen
    pamela martha debra amanda stephanie carolyn christine marie janet
    catherine frances ann joyce diane alice julie heather teresa
    doris gloria evelyn jean cheryl mildred katherine joan ashley
    judith rose janice kelly nicole judy christina kathy theresa
    beverly denise tammy irene jane lori rachel marilyn andrea
    kathryn louise sara anne jacqueline wanda bonnie julia ruby
    lois tina phyllis norma paula diana annie lillian emily
    robin peggy crystal gladys rita dawn connie florence tracy
  ]
  NAMES = MALE_NAMES+FEMALE_NAMES

  def self.pick(n=1)
    NAMES.sample
  end

  def self.male(n=1)
    MALE_NAMES.sample
  end

  def self.female(n=1)
    FEMALE_NAMES.sample
  end

  def self.pick_even(n=1)
    if n.to_i <= 1
      pick
    else
      halfs = [n / 2, n - n / 2].shuffle!
      (MALE_NAMES.sample(halfs[0]) + FEMALE_NAMES.sample(halfs[1])).shuffle
    end
  end
end
