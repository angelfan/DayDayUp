Timecop.freeze
用来处理需要冻结时间的测试 比如根据不同的时间生成不同的md5码
```ruby
it 'status Error, code is expired' do
  Timecop.freeze(Time.zone.yesterday)
  coupon = create(:coupon, expired_at: Time.zone.today, user_usage_count_limit: -1)
  Timecop.return
  get :validate, code: coupon.code
  expect(response_json['status']).to eq('Error')
  expect(response_json['message'][0]).to eq('Code is expired')
end
```