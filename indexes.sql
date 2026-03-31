-- Q1: البحث عن الجرائم
CREATE INDEX idx_crime_city_type ON crime_scene_report(city, type);

-- Q2, Q6, Q8: تسريع الربط بين الأشخاص والرخص
CREATE INDEX idx_person_license_id ON person(license_id);

-- Q3: تسريع البحث عن تاريخ دخول الجيم
CREATE INDEX idx_checkin_date ON get_fit_now_check_in(check_in_date);

-- Q4: تسريع البحث عن حالة العضوية (Gold)
CREATE INDEX idx_member_status ON get_fit_now_member(membership_status);

-- Q5: تسريع البحث عن تواريخ فيسبوك
CREATE INDEX idx_facebook_date ON facebook_event_checkin(date);

-- Q6: تسريع البحث عن لون الشعر ونوع السيارة
CREATE INDEX idx_license_hair_car ON drivers_license(hair_color, car_make);