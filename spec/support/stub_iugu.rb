def stub_iugu(params = {})
  conf = {
      filename: 'create',
      method: :post,
      url: 'https://api.iugu.com/v1/invoices',
      headers: {'Accept'=>'application/json',
                'Accept-Charset'=>'utf-8',
                'Accept-Encoding'=>'gzip, deflate',
                'Accept-Language'=>'pt-br;q=0.9,pt-BR',
                'Content-Type'=>'application/json; charset=utf-8',
                'User-Agent'=>'Iugu RubyLibrary'},
      body: hash_including({'method' => 'bank_slip'})
  }.merge(params)

  create_response = JSON.parse File.read("spec/fixtures/iugu_responses/#{conf[:filename]}.json")

  stub_request(conf[:method], conf[:url]).
      with(headers: conf[:headers],
           body: conf[:body]).
      to_return(body: create_response.to_json, status: 200)
end