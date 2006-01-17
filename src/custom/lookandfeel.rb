#!/usr/bin/env ruby
# Html::Custom::Lookandfeel -- ydim -- 12.01.2006 -- hwyss@ywesee.com

require 'sbsm/lookandfeel'

module YDIM
	module Html
		module Custom
class Lookandfeel < SBSM::Lookandfeel
	DICTIONARIES = {
		'de'	=>	{
			:address_lines							=>	'Adresse',
			:contact										=>	'Kontaktperson',
			:copyright									=>	'&copy; ywesee GmbH', 
			:create_debitor							=>	'Neuer Kunde',
			:date												=>	'Rechnungsdatum',
			:date_format								=>	'%d.%m.%Y',
			:debitors										=>	'Kunden',
			:debitor_name								=>	'Kunde',
			:debitor_type								=>	'Kundenart',
			:description								=>	'Beschreibung',
			:dt_hosting									=>	'Hosting-Kunde',
			:dt_info										=>	'Medi-Information',
			:dt_insurance								=>	'Krankenkasse',
			:dt_pharma									=>	'Pharma-Firma',
			:e_domainless_email_address	=>	'Wir akzeptieren keine lokalen Email-Adressen.',
			:e_invalid_email_address		=>	'Die angegebene Email-Adresse ist ungültig.',
			:email											=>	'Email',	
			:e_bygone_date							=>	'Bitte geben Sie ein Datum an, welches in der Zukuft liegt.',
			:e_missing0									=>	'Bitte geben Sie das Feld "',
			:e_missing1									=>	'" an.',
			:head												=>	'YDIM',
			:hinv_3											=>	'Vierteljährlich',
			:hinv_6											=>	'Halbjährlich',
			:hinv_12										=>	'Jährlich',
			:hosting_invoice_date				=>	'Nächste Rechnung',
			:hosting_invoice_interval		=>	'Rechnungs-Intervall',
			:hosting_price							=>	'Monatlicher Betrag',
			:invoices										=>	'Rechnungen',
			:location										=>	'PLZ/Ort',
			:login											=>	'Login',
			:logout											=>	'Logout',
			:name												=>	'Firma',
			:pass												=>	'Passwort',
			:th_debitor_name						=>	'Name',
			:th_debitor_type						=>	'Kundenart',
			:th_email										=>	'Email',
			:th_formatted_date					=>	'Datum',
			:th_name										=>	'Name',
			:th_price										=>	'Preis',
			:th_quantity								=>	'Anzahl',
			:th_text										=>	'Positionstext',
			:th_time										=>	'Zeit',
			:th_total_netto							=>	'Total Netto',
			:th_unique_id								=>	'ID',
			:th_unit										=>	'Einheit',
			:time_format								=>	'%d.%m.%Y %H:%M:%S',
			:toggle_paid								=>	'offen -> bezahlt',
			:toggle_unpaid							=>	'bezahlt -> offen',
			:total_brutto								=>	'Total Brutto',
			:total_netto								=>	'Total Netto',
			:unique_id									=>	'ID',
			:update											=>	'Speichern',
			:vat												=>	'MwSt. (7.6%)',
		},
	}
	RESOURCES = {
		:css				=>	'ydim.css',
		:javascript	=>	'javascript',
	}
end
		end
	end
end
