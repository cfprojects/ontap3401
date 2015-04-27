name=Number
actionnumber=Number
percentage=percent
adjustment=plus
adjustmentgroup=Or
compnumber=Of Value
literalnumber=Number 
format_eq=is equal to
format_gte=is no less than
format_lte=is no more than
format_gt=is greater than
format_lt=is less than
percentof=<xsl:value-of select="concat(' ',$percentamount,' of ')" />
adjustformat=<xsl:if test="number(@adjustment) > 0">+</xsl:if><xsl:value-of select="$adjustmentamount" />
describe=<xsl:value-of select="concat($actionnumber,' ',$format,$percentage,' ',$compnumber,' ',$adjustment)" />