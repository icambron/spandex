describe Spandex do
  it "is a finder" do
    Spandex.new("somepath").is_a? Spandex::Finder
  end
end
