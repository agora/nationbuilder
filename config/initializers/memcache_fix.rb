# FIX FROM http://kballcodes.com/2009/09/05/rails-memcached-a-better-solution-to-the-undefined-classmodule-problem/
# See other:
# http://blog.cbciweb.com/2007/05/31/workaround-the-memcached-undefined-class-module-bug
# http://thewebfellas.com/blog/2008/6/9/rails-2-1-now-with-better-integrated-caching
# http://www.philsergi.com/2007/06/rails-memcached-undefinded-classmodule.html

class << Marshal
  def load_with_autoload(*args)
    begin
      load_without_autoload(*args)
    rescue [ArgumentError, NameError] => ex
      msg = ex.message
      if msg =~ /undefined class\/module/
        mod = msg.split(' ').last
        if Dependencies.load_missing_constant(self, mod.to_sym)
          load(*args)
        else
          raise ex
        end
      else
        raise ex
      end
    end
  end
  alias_method :load_without_autoload, :load
  alias_method :load, :load_with_autoload
end