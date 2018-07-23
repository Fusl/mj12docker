<MJ12node xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" Version="1.0.0" NewVersionURL="http://www.majestic12.co.uk/files/mj12node/versions.txt">
  <WebCrawlerCfg Active="true" LastCleanUp="{{MJ12node>WebCrawlerCfg:LastCleanUp}}">
    <Common WorkingPath="data/" PreCacheBuckets="5" />
    <Delays URLsBatchFetchDelay="120" ArchivingDelay="0" URLBucketLoadDelay="100" UploadManagerCheckDelay="15" RobotsTXTDelay="0" RetrievedURLsDelay="0" ParsingLinksWorkSliceDelay="0" />
    <Barrels TempDir="" NewBarrels="barrels/new" OldBarrels="barrels/old" WorkBarrels="barrels/work" FileExtention=".gz" TempFileExtention=".txt" ExternalArchiverPath="" EnableBarrelSorting="false" MinimiseMemoryUsageByCrawlBuffers="false" />
    <Crawling MaxOpenBuckets="{{MJ12node>WebCrawlerCfg>Crawling:MaxOpenBuckets}}" StartCrawlingIfUploadsLessThan="5" />
    <URLs NewURLs="urls/new" OldURLs="urls/old" WorkURLs="urls/work" />
    <Profiles>
    </Profiles>
  </WebCrawlerCfg>
  <DatabaseCfg DataBaseFileName="data/peer.db" QueryFileName="@node.sql" />
  <IdentityCfg EmailAddress="{{MJ12node>IdentityCfg:EmailAddress}}" Password="" NickName="{{MJ12node>IdentityCfg:NickName}}" NodeHash="" NodeName="{{MJ12node>IdentityCfg:NodeName}}" Country="" PrefDomains="" />
  <PeerNodeCfg NodeName="{{MJ12node>PeerNodeCfg:NodeName}}" ControlFilePath="">
    <Priorities ProcessPriority="High" CrawlThreadPriority="High" WorkerThreadPriority="High" URLmanagerThreadPriority="High" UploadManagerThreadPriority="High" />
  </PeerNodeCfg>
  <SuperPeerNodeCfg UploadsNoDelay="true">
    <Nodes UpdateURL="http://www.majestic12.co.uk/projects/dsearch/superpeers.txt">
      <Node Address="http://crawl.majestic12.co.uk" LastSeen="" Ping="" Version="2" />
    </Nodes>
  </SuperPeerNodeCfg>
  <Connection VerbalName="" DownStream="{{MJ12node>Connection:DownStream}}" UpStream="{{MJ12node>Connection:UpStream}}" DownStreamLimit="100" UpStreamLimit="100" UseDirectConnection="false">
    <Proxy Address="" UserName="" Password="" MicrosoftAuth="false" />
  </Connection>
</MJ12node>
