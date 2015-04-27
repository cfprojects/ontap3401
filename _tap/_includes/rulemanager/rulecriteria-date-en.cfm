name=Date
actiondate=Date
adjustment=Is At Least
isMinimum=at least
datepart_d=days
datepart_w=weeks
datepart_m=months
before=before
after=after
compdate=Comparison Date
literaldate=Or Literal
describe_adjustment=<xsl:value-of select="concat($isminimum,' ',@adjustment,' ',$datepart)" />
describe=<xsl:value-of select="concat($actiondate,' is ',$adjustment,' ',$beforeorafter,' ',$compdate)" />