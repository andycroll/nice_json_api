require 'test_helper'

class NiceJsonApiTest < Minitest::Test
  def test_get_request
    stub_request(:get, 'https://www.example.com')
      .with(headers: { 'Accept': 'application/json' })
      .to_return(body: '{ "parent": { "one": "two" }, "array": [{}, { "three": 4 }, "five"]}')

    resp = NiceJsonApi::Response.new('https://www.example.com')

    assert_equal Hash[{ 'parent' => { 'one' => 'two' }, 'array' => [{}, { 'three' => 4 }, 'five'] }], resp.body
    assert_equal '{ "parent": { "one": "two" }, "array": [{}, { "three": 4 }, "five"]}', resp.raw_body
    assert_equal '200', resp.code
    assert_equal '', resp.message
  end

  def test_hash_get_request
    stub_request(:get, 'https://www.example.com')
      .with(headers: { 'Accept': 'application/json' })
      .to_return(body: '{}')

    resp = NiceJsonApi::Response.new('https://www.example.com')

    assert_equal({}, resp.body)
    assert_equal '{}', resp.raw_body
    assert_equal '200', resp.code
    assert_equal '', resp.message
  end

  def test_empty_get_request
    stub_request(:get, 'https://www.example.com')
      .with(headers: { 'Accept': 'application/json' })
      .to_return(body: '')

    resp = NiceJsonApi::Response.new('https://www.example.com')

    assert_equal({}, resp.body)
    assert_equal '', resp.raw_body
    assert_equal '200', resp.code
    assert_equal '', resp.message
  end

  def test_null_get_request
    stub_request(:get, 'https://www.example.com')
      .with(headers: { 'Accept': 'application/json' })
      .to_return(body: 'null')

    resp = NiceJsonApi::Response.new('https://www.example.com')

    assert_equal({}, resp.body)
    assert_equal 'null', resp.raw_body
    assert_equal '200', resp.code
    assert_equal '', resp.message
  end

  def test_request_with_no_schema
    stub_request(:get, 'https://www.example.com')
      .with(headers: { 'Accept': 'application/json' })
      .to_return(body: '{ "status": "success" }')

    resp = NiceJsonApi::Response.new('www.example.com')

    assert_equal Hash[{ 'status' => 'success' }], resp.body
    assert_equal '{ "status": "success" }', resp.raw_body
    assert_equal '200', resp.code
    assert_equal '', resp.message
  end

  def test_request_with_http_to_https_redirect
    stub_request(:get, 'http://www.example.com')
      .with(headers: { 'Accept': 'application/json' })
      .to_return(status: 301, headers: { 'Location' => 'https://www.example.com' })

    stub_request(:get, 'https://www.example.com')
      .with(headers: { 'Accept': 'application/json' })
      .to_return(body: '{ "status": "success" }')

    resp = NiceJsonApi::Response.new('http://www.example.com')

    assert_equal Hash[{ 'status' => 'success' }], resp.body
    assert_equal '{ "status": "success" }', resp.raw_body
    assert_equal '200', resp.code
    assert_equal '', resp.message
  end

  def test_request_with_several_redirects
    stub_request(:get, 'http://www.example.com/api?key=value')
      .with(headers: { 'Accept': 'application/json' })
      .to_return(status: 301, headers: { 'Location' => 'https://www.example.com/v2' })

    stub_request(:get, 'https://www.example.com/v2')
      .with(headers: { 'Accept': 'application/json' })
      .to_return(status: 301, headers: { 'Location' => 'https://beta.example.com/v3' })

    stub_request(:get, 'https://beta.example.com/v3')
      .with(headers: { 'Accept': 'application/json' })
      .to_return(body: '{ "status": "success" }')

    resp = NiceJsonApi::Response.new('http://www.example.com/api?key=value')

    assert_equal Hash[{ 'status' => 'success' }], resp.body
    assert_equal '{ "status": "success" }', resp.raw_body
    assert_equal '200', resp.code
    assert_equal '', resp.message
  end

  def test_post_request
    stub_request(:get, 'https://www.example.com')
      .with(headers: { 'Accept': 'application/json' })
      .to_return(body: '{ "status": "success" }')

    resp = NiceJsonApi::Response.new('www.example.com')

    assert_equal Hash[{ 'status' => 'success' }], resp.body
    assert_equal '{ "status": "success" }', resp.raw_body
    assert_equal '200', resp.code
    assert_equal '', resp.message
  end

  def test_post_request_with_json_body
    stub_request(:get, 'https://www.example.com')
      .with(headers: { 'Accept': 'application/json', 'Content-Type' => 'application/json' },
            body: '{"parent":{"one":"two"}}')
      .to_return(body: '{ "status": "success" }')

    resp = NiceJsonApi::Response.new('https://www.example.com', body: { parent: { one: 'two' } })

    assert_equal Hash[{ 'status' => 'success' }], resp.body
    assert_equal '{ "status": "success" }', resp.raw_body
    assert_equal '200', resp.code
    assert_equal '', resp.message
  end

  def test_request_with_basic_auth
    stub_request(:get, 'https://www.example.com')
      .with(basic_auth: %w[u pass], headers: { 'Accept': 'application/json' })
      .to_return(body: '{ "status": "success" }')

    resp = NiceJsonApi::Response.new('https://www.example.com',
                                     auth: { user: 'u', password: 'pass' })

    assert_equal Hash[{ 'status' => 'success' }], resp.body
    assert_equal '{ "status": "success" }', resp.raw_body
    assert_equal '200', resp.code
    assert_equal '', resp.message
  end

  def test_request_with_header_auth
    stub_request(:get, 'https://www.example.com')
      .with(headers: { 'Accept': 'application/json', 'X-Header-Name': '1234' })
      .to_return(body: '{ "status": "success" }')

    resp = NiceJsonApi::Response.new('https://www.example.com',
                                     auth: { header: { name: 'X-Header-Name', value: '1234' } })

    assert_equal Hash[{ 'status' => 'success' }], resp.body
    assert_equal '{ "status": "success" }', resp.raw_body
    assert_equal '200', resp.code
    assert_equal '', resp.message
  end

  def test_request_with_bearer_token
    stub_request(:get, 'https://www.example.com')
      .with(headers: { 'Accept': 'application/json', 'Authorization': 'Bearer token1234' })
      .to_return(body: '{ "status": "success" }')

    resp = NiceJsonApi::Response.new('https://www.example.com',
                                     auth: { bearer: 'token1234' })

    assert_equal Hash[{ 'status' => 'success' }], resp.body
    assert_equal '{ "status": "success" }', resp.raw_body
    assert_equal '200', resp.code
    assert_equal '', resp.message
  end
end
