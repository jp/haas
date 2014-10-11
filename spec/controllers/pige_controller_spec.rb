require 'spec_helper'
describe PigeController do
  describe "run add_member" do
    before do
      Member.destroy_all
      PigeController.add_member Faker::Name.name
    end
    it "creates a user" do
      expect(Member.all.count).to eq(1)
    end
  end

  describe "run add_member with an existing user name" do
    before do
      Member.destroy_all
      first_member = Member.create name: Faker::Name.name
      PigeController.add_member first_member.name
    end

    it "does not create another user" do
      expect(Member.all.count).to eq(1)
    end
  end

  describe "run add_member with a partner name" do
    before do
      Member.destroy_all
      PigeController.add_member Faker::Name.name, Faker::Name.name
    end
    it "creates two users" do
      expect(Member.all.count).to eq(2)
    end
    it "associates the partners" do
      expect(Member.first.id).to eq(Member.last.partner_id)
      expect(Member.last.id).to eq(Member.first.partner_id)
    end
  end

  describe "run add_member with a partner name for two existing members" do
    before do
      Member.destroy_all
      @first_member = Member.create name: Faker::Name.name
      @second_member = Member.create name: Faker::Name.name

      PigeController.add_member @first_member.name, @second_member.name
    end
    it "creates only two users" do
      expect(Member.all.count).to eq(2)
    end
    it "associates the partners" do
      expect(Member.first.id).to eq(Member.last.partner_id)
      expect(Member.last.id).to eq(Member.first.partner_id)
    end
  end

  describe "get_pige on a valid user name" do
    before do
      # create a random family
      Array(5..10).sample.times.map do
        FactoryGirl.create(:member)
      end

      # Run the automated pige
      PigeController.automated_pige

      @result = PigeController.get_pige Member.all.sample.name
    end

    it "returns a name" do
      expect(Member.find_by(name:@result).name).to eq(@result)
    end
  end

  describe "get_pige on a invalid user name" do
    before do
      # create a random family
      Array(5..10).sample.times.map do
        FactoryGirl.create(:member)
      end

      # Run the automated pige
      PigeController.automated_pige

      @result = PigeController.get_pige Faker::Name.name
    end

    it "returns an error" do
      expect(@result).to eq(I18n.t('pige.member_not_found'))
    end
  end

  describe "get_pige on a valid user name before running the automated pige" do
    before do
      Member.destroy_all
      # create a random family
      Array(5..10).sample.times.map do
        FactoryGirl.create(:member)
      end

      @result = PigeController.get_pige Member.all.sample.name
    end
    it "returns an error" do
      expect(@result).to eq(I18n.t('pige.pige_not_found'))
    end
  end

  describe "fake an automated_pige, forcing to swap a pick" do
    before do
      Member.destroy_all

      member1 = FactoryGirl.create(:member)
      member2 = FactoryGirl.create(:member)
      member3 = FactoryGirl.create(:member)
      member4 = FactoryGirl.create(:member)

      member3.add_partner member4

      member1.pige_id = member2.id
      member2.pige_id = member4.id
      member3.pige_id = member1.id

      member1.save
      member2.save
      member3.save

      member4.pige_member
    end

    it "give a pige to everybody" do
      expect(Member.where("pige_id IS NOT NULL").count).to eq(Member.count)
    end
  end

  describe "run a valid automated_pige" do
    before do
      Member.destroy_all

      # create a random family
      Array(5..40).sample.times.map do
        FactoryGirl.create(:member)
      end

      # create random partners
      Array(2..15).sample.times.map do
        Member.all.sample.add_partner Member.all.sample
      end

      # Run the automated pige
      @return_value = PigeController.automated_pige
    end

    it "give a pige to everybody" do
      expect(Member.where("pige_id IS NOT NULL").count).to eq(Member.count)
    end

    it "returns not false" do
      expect(@return_value).not_to eq(false)
    end
  end

  describe "run an invalid automated_pige" do
    before do
      Member.destroy_all

      # create a pige with 3 members
      3.times.map do
        FactoryGirl.create(:member)
      end

      # two are partners
      Member.last.add_partner Member.first

      # Run the automated pige
      @return_value = PigeController.automated_pige
    end

    it "doesn't return false" do
      expect(@return_value).to eq(false)
    end
  end
end
