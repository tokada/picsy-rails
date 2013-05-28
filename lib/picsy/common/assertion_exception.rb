# Created on 2004/02/06

# @author Kazutoshi Ono<ono@appresso.com>
class AssertionException < RuntimeException
  def initialize(msg)
    super(msg)
  end
end
