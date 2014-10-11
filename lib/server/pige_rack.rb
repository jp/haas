class PigeRack
  require 'rack'

  def self.start
    default = Proc.new {|env| [200, {"Content-Type" => "text/html"}, ['Not found']]}

    builder = Rack::Builder.new do
      use Rack::CommonLogger

      map '/' do
        run default
      end

      map '/pige' do
        map '/' do
          run Proc.new { |env|
            output = PigeController.get_pige env['REQUEST_PATH'].sub %r{^/pige/}, ''
            [ 200, {'Content-Type' => 'text/html'}, [output] ]
          }
        end
      end
    end

    Rack::Handler::Thin.run(builder, :Port => 9000 )
  end
end