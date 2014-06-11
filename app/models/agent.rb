class Agent < ActiveFedora::Rdf::Resource
  configure type: RDF::FOAF.Agent

  property :name, predicate: RDF::FOAF.name
  property :familyName, predicate: RDF::FOAF.familyName
  property :givenName, predicate: RDF::FOAF.givenName
  property :orcid, predicate: RDF::URI('http://purl.org/spar/scoro/hasORCID')


  def get_orcid
    return orcid unless orcid.empty?
    request_uri = URI("http://pub.orcid.org/search/orcid-bio/?q=family-name:#{familyName}+AND+given-names:#{givenName}")
    results = Nokogiri::XML(Net::HTTP.get(request_uri))
    orcid_element = results.css('orcid-search-result orcid-identifier path').first
    orcid = orcid_element.text unless orcid_element.nil?
    orcid
  end

  def givenName
    givenName ||= parseName[:givenName]
  end

  def familyName
    familyName ||= parseName[:familyName]
  end

  private

  # returns { :familyName => 'last', :givenName => 'first' }
  def parseName
    return { :familyName => nil, :givenName => nil } if name.empty?
    names = name.first.split(",").map(&:strip)
    { :familyName => names[0], :givenName => names[1] } 
  end
end
