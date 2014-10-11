class PigeController
  def self.add_member member_name, partner_name = nil
    member = Member.find_or_create_by(name: member_name)
    if partner_name
      member.add_partner Member.find_or_create_by(name: partner_name)
    end
  end

  def self.get_pige member_name
    if member = Member.find_by(name: member_name)
      if member.pige
        member.pige.name
      else
        I18n.t('pige.pige_not_found')
      end
    else
      I18n.t('pige.member_not_found')
    end
  end

  def self.automated_pige
    # Reset the pige
    Member.update_all pige_id: nil
    Member.all.each do |member|
      return false unless member.pige_member
    end
  end
end
