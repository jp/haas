require 'spec_helper'
describe Member do
  describe "create" do
    name = Faker::Name.name
    member = FactoryGirl.create(:member, name: name)
    it "is equal to the original name" do
      expect(member.name).to eq(name)
    end
    it "has no partner set" do
      expect(member.partner_id).to eq(nil)
    end
    it "has no pige set" do
      expect(member.pige_id).to eq(nil)
    end
  end

  describe "with an existing user name" do
    before do
      name = Faker::Name.name
      FactoryGirl.create(:member, name: name)
      @bad_member = FactoryGirl.build(:member, name: name)
    end

    it "should raise an error" do
      expect { @bad_member.save! }.to raise_error ActiveRecord::RecordInvalid
    end
  end

  describe "add partner to member" do
    member1 = FactoryGirl.create(:member)
    member2 = FactoryGirl.create(:member)
    member1.add_partner(member2)

    it "should add a partner to member1" do
      expect(member1.partner_id).to eq(member2.id)
    end

    it "should add a partner to member2" do
      expect(member2.partner_id).to eq(member1.id)
    end
  end

  describe "pige another member" do
    Array(2..5).sample.times.map do
      FactoryGirl.create(:member)
    end

    member = FactoryGirl.create(:member)
    member.pige_member

    it "should have a piged member" do
      expect(member.pige_id).not_to eq(nil)
    end
  end

  describe "pige another member when the last member is itself" do
    Member.destroy_all
    member1 = FactoryGirl.create(:member)
    member2 = FactoryGirl.create(:member, pige_id: member1.id)
    member1.update_attributes(pige_id: member2.id)
    member3 = FactoryGirl.create(:member)

    member3.pige_member

    it "should have a piged member" do
      expect(member3.pige_id).not_to eq(nil)
    end
  end

  describe "pige another member when the last two members are partners" do
    before do
      Member.destroy_all
      member1 = FactoryGirl.create(:member)
      member2 = FactoryGirl.create(:member, pige_id: member1.id)
      member1.update_attributes(pige_id: member2.id)
      @partner1 = FactoryGirl.create(:member)
      @partner2 = FactoryGirl.create(:member)
      @partner1.add_partner @partner2
      @partner2.add_partner @partner1

      @partner1.pige_member
      @partner2.pige_member
    end

    it "should have a piged member" do
      expect(@partner1.pige_id).not_to eq(nil)
      expect(@partner2.pige_id).not_to eq(nil)
    end
  end

end
