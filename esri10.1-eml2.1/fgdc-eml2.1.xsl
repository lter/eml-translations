<?xml version="1.0" encoding="UTF-8"?>
<!-- 
	Latest update:  made changes with contact information, as esri changed their fgdc contact tags.
	3/14/2013.  Theresa valentine
	
	changes have been made over the winter of 2013, cleaning up problems with spatialraster, package-id, and some other
	tags resulting from changes at arcgis 10.1    Further work needs to be done on the custom units (which now have to be added
	by hand at the end of the eml document.  Corrected problems with vertical accuracy section.  Fixed to collect correct information 
	about cellsize and number of raster bands.  Note:  need to run the argisfgdc_test.xsl from arc to get the correct information in the raster
	fields.   
	
	2/21/2013  Theresa Valentine and Inigo San Gil
	
    Compliance with EML-2.1.0 requires no empty tags.  Many checks for content have been added.

    We cannot assume that mandatory placeholder in ESRI are populated, so we need a default content in
    case compliance policy has been violated.  Many checks need to be added
    -keywordSet group restructured to fix a bug that produced multiple instances of keyword set sources (keywordThesaurus).
    -"Browse" element from FGDC, mapped to "supplemental information" in the data resource module of EML has been fixed(title-para problem)
    -Additional checks have been added for the "intellectual rights" section, documentation must specify changes needed in case a document
    needs special or customized access and use constraints.
    -EML's geographicDescription was not populated, creating a fatal error.  In case the tag is non-existing (not in FGDC core), we attempt
    to populate the tag with any "place" type of keywords.  If that fails, we declare that there is no descriptive info about the plot/site.
    -bug fix: calendar date in ESRI is not in EML's required ISO format, created routine FormatDate to translate.
    -bug fix: temporal coverage: rangeOfDates was not followed by beginDate tags and endDate tag.
    -bug fix: unit was not mapped correctly (at measurementScale, attribute level), not wrapped by customUnit.  
    -bogus check for deciding interval or ratio removed  : the minimum value of a ratio-type attribute being bigger than 0 does not grant that is of type "interval"
    -attribute accuracy value at attribute level added.
    -spatial reference: the unit in geodetic needs to be within the tag attribute, not a value in the tag
    -additional Metadata for custom units - <unitList> etc.
    -checks added to prevent empty tags (xsl:if ... !='')
    -other things i cannot remember
	  updated for the Andrews site, by Theresa Valentine 9/15/2011
	  changes made to the spatial vector and spatial raster sections.
	  specifially to match the Andrews database codes (where I place them in other citation 
	  and to make sure my on-line linkage is correct.  
	  I also changed the externally defined format to match my zip files, depending on if it's raster 
	  vector data.
	  The spatial raster section wasn't picking up my values for value, so I changed the link there.
	  
       File: esri2eml.xsl
        Author: Inigo San Gil
        Date: 2008/08/14
        Revision: 1.3
Changes Dec 2009

Some missing mappings:
* added contact email mapping. added 7 lines around line 1170
* added metadata provider info check - about 70 lines after creator (beginning)
* added esri-specific attribute descriptors to avoid leakage (not really necessary)

Changes: on Aug 2008
  
   *Documented specific site-dependent info within the script  as XML comments 
   *Browse Graphic complex ESRI element section of the crosswalk enhanced
   *Added the LTER Data Network Policies.

        File: esri2eml.xsl
        Author: Inigo San Gil
        Date: 2007/02/26
        Revision: 1.2

   ** Log of Changes: Inigo San Gil, May 2006
   ** header changes: root element, new attributes, including migration to EML 2.1.0
   * TODO data format checker. (december 2003 to 2003-12-01, etc)
   ** Keywords: Thesaurus placed after regular, custom. keywords (was wrong order)
   ** Temporal Coverage: Three prong error:1/ ESRI XPath fixed. 2/ Swapped location with Geogrpahic Coverage element. 3/ Wrong Xpath for EML/.
   ** <geographicDescrition> mandatory in EML 2.1.0, kludge placed. (place keywords, or abstract)
   ** Contact info - stylesheet pushed an empty individualName tag.
   ** Publisher info encroached between contact info, fixed, placed afterwards.
   **: geography type, variable construct (XSL intepreter dependent) replaced by a Choose construct.
 
  * TODO: attributes lacking sufficient metadata are parsed and placed with incomlete fields (no <measurementScale>, since FGDC does not enforce corresponding attribute section: Workaround: when no attribute domain (measurementScale) is specified, default to textdomain with attribute definition value 
  * TODO: not enough types for horizontal coordinate system names? suggest more to eml-dev? lax field?
  ** make accuracy optional  Workaround: call to accuracy templates made optional by placing test of content in ESRI original format.
 
  ** Intrinsic problem: geometry and geometricObjectCount have cardinality one, while in ESRI we have many elements of type
metadata/spdoinfo/ptvctinf/sdtsterm/ptvctcnt and metadata/spdoinfo/ptvctinf/sdtsterm/sdtstype. Now grab only first..
 
    Log of Changes: February 2007
       A couple of bugs and structure addition to accomodate a perl companion to add proper "best practices compliant" packageIds.
       -fixed optional accuracy 
	   -expanded keywordSet collection
	   -fixed access element -whenever possible, make site owned- and always public read.
	   -added intellectual rights, if those exist
	   -expanded collection of distribution info
	   -expanded "coverage" and "publisher" and "pubPLace"
        set up cases for a perl script companion (esri2emlSupport.pl). additional fields in raw esri field should be innocous enough so the stylesheet 
		produces eml without this perl companion code 
	   -added maintenance section
       -started adding content checks to avoid ending up with non-valid EML (checks for pubDate, abstract, additionalinfo, purpose, maintenance, distribution, intellectual rights, contact, publisher:: many MORE would be advisable)
       -additionalInfo is optional, check placed before attempt to transform this EML element whether at least one of the fields therein is populated in ESRI. (  this OR this OR this OR..) type of statement 
    -perl introduces a proper packageId and an access tag as for "provenance". 
  -->
<!--
       '$RCSfile: esri2eml_for_LTER.xsl,v $'
        '$Author: isangil $'
          '$Date: 2008/08/15 21:14:14 $'
      '$Revision: 1.1 
    Copyright: 2003 Arizona State University
    
    This material is based upon work supported by the National Science Foundation 
    under Grant No. 9983132 and 0219310. Any opinions, findings and conclusions or recommendation 
    expressed in this material are those of the author(s) and do not necessarily 
    reflect the views of the National Science Foundation (NSF).  
                  
    For Details: http://ces.asu.edu/bdi

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:eml="eml://ecoinformatics.org/eml-2.1.0" xmlns:stmml="http://www.xml-cml.org/schema/stmml"
	xmlns:sw="eml://ecoinformatics.org/software-2.1.0"
	xmlns:cit="eml://ecoinformatics.org/literature-2.1.0"
	xmlns:ds="eml://ecoinformatics.org/dataset-2.1.0"
	xmlns:prot="eml://ecoinformatics.org/protocol-2.1.0"
	xmlns:doc="eml://ecoinformatics.org/documentation-2.1.0"
	xmlns:res="eml://ecoinformatics.org/resource-2.1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<!--xsl:stylesheet version="1.0" xml:lang="en" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"-->
	<xsl:output method="xml" indent="yes"/>
	<xsl:template match="/">
		<xsl:element name="eml:eml">
			<!--xsl:element name="eml:eml" namespace="eml://ecoinformatics.org/eml-2.1.0"-->
			<!--xsl:attribute name="xmlns:xsi">http://www.w3.org/2001/XMLSchema-instance</xsl:attribute-->
			<xsl:attribute name="xsi:schemaLocation">eml://ecoinformatics.org/eml-2.1.0
				http://nis.lternet.edu/schemas/EML/eml-2.1.0/eml.xsd</xsl:attribute>
			<xsl:attribute name="packageId">
				<!-- Here we need a Site and Metadata Record specific "packageId". 
				       It should consist of a scope (I.e; knb-lter-acr) plus a numeric identifier (I.e; 0028) and a numeric revision (I.e;0003)
                       For now, the packageId is synchronized with the Metacat repository through the harvest list entry for this document.
                       The user has the option of adding manually or via Perl script a packageId to the ESRI record.
					   If no packageId is added directly under the root element 
                       I.e:<metadata><packageId>knb-lter-arc.0028.0003</packageId>...</metadata>
					   then this stylsheet defaults to the MetaID assigned by ESRI - which is not LTER Best Practices compliant
                 -->
				<xsl:choose>
					<xsl:when test="metadata/packageId">
						<!-- an ad-hoc packageID was added a posteriori to the original ESRI record-->
						<xsl:value-of select="metadata/packageId"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="'knb-lter-and.'"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:attribute name="system"
				>http://andrewsforest.oregonstate.edu/data/mastercatalog.cfm?topnav=97</xsl:attribute>
			<xsl:choose>
				<xsl:when test="metadata/access">
					<xsl:copy-of select="metadata/access"/>
				</xsl:when>
				<xsl:otherwise>
					<!-- we do not have precise information about the data set owner -->
					<access>
						<!-- change this first group with appropriate values for your site, example: uid=AND-->
						<xsl:attribute name="scope">
							<xsl:value-of select="'document'"/>
						</xsl:attribute>
						<xsl:attribute name="order">
							<xsl:value-of select="'allowFirst'"/>
						</xsl:attribute>
						<xsl:attribute name="authSystem">
							<xsl:value-of select="'knb'"/>
						</xsl:attribute>
						<allow>
							<principal>uid=AND,o=lter,dc=ecoinformatics,dc=org</principal>
							<permission>all</permission>
						</allow>
						<allow>
							<principal>public</principal>
							<permission>read</permission>
						</allow>
					</access>
				</xsl:otherwise>
			</xsl:choose>
			<dataset>
				<xsl:attribute name="id">
					<xsl:value-of select="metadata/Esri/MetaID"/>
				</xsl:attribute>
				<xsl:attribute name="system">ESRI MetaID</xsl:attribute>
				<xsl:if test="metadata/Esri/MetaID !=''">
					<alternateIdentifier>
						<xsl:value-of select="metadata/Esri/MetaID"/>
					</alternateIdentifier>
				</xsl:if>
				<xsl:if test="metadata/packageId !=''">
					<alternateIdentifier>
						<xsl:value-of select="metadata/packageId"/>
						<!-- an ad-hoc packageID was added a posteriori to the record -->
					</alternateIdentifier>
				</xsl:if>
				<xsl:for-each select="metadata/idinfo/citation/citeinfo/ftname">
					<shortName>
						<xsl:value-of select="."/>
					</shortName>
				</xsl:for-each>
				<xsl:for-each select="metadata/idinfo/citation/citeinfo/title">
					<title>
						<xsl:value-of select="."/>
					</title>
				</xsl:for-each>
				<!-- Here is one of the weaknesses of this crosswalk.

				The problem is the different granularity of the XML standards:
				ESRI piles all the author names in one placeholder (XML element)
				/idinfo/citation/citeinfo/origin
				whereas EML reserves a placeholder group for each author
				and also, EML has placeholders for first name, last name, suffix, etc.
				An automatic conversion needs to be aided by some pattern matching
				capable language, (such as Perl) and it does not warrant success
				as the practices to enter information in this ESRI placeholder vary

				When using a perl-parser companion, a user may attempt to
				pre-process the ESRI record to breakdown this placeholder into
				proper fields as well as take care of other site-specific information
				such as data policies, packageIds and the like.

				If no perl parser or pre-processor exists, then this XSLT just
				 stores all the info in ESRIs "origin" placeholder in EML's creator's 
				lastname.  The results could include many name-lastname duples in
				the aforementioned EML "last name" field.

				-->
				<xsl:choose>
					<!-- try FGDC origin encoder -->
					<xsl:when test="/metadata/idinfo/citation/citeinfo/origin!=''">
						<xsl:for-each select="/metadata/idinfo/citation/citeinfo/origin">
							<xsl:element name="creator">
								<individualName>
									<surName>
										<xsl:value-of select="."/>
									</surName>
								</individualName>
							</xsl:element>
						</xsl:for-each>
					</xsl:when>
					<xsl:when test="/metadata/dataIdInfo/idCitation">
						<!-- try ESRI encoding of creator -->
						<xsl:for-each
							select="/metadata/dataIdInfo/idCitation/citRespParty[role/RoleCd/@value = 6]">
							<xsl:if test="(./rpIndName != '')">
								<creator>
									<individualName>
										<surName>
											<xsl:value-of select="./rpIndName"/>
										</surName>
									</individualName>
								</creator>
							</xsl:if>
							<xsl:if test="(./rpOrgName != '')">
								<xsl:element name="creator">
									<organizationName>
										<xsl:value-of select="./rpOrgName"/>
									</organizationName>
								</xsl:element>
							</xsl:if>
							<xsl:if test="(./rpPosName != '')">
								<xsl:element name="creator">
									<positionName>
										<xsl:value-of select="./rpPosName"/>
									</positionName>
								</xsl:element>
							</xsl:if>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<!-- if this is true, then we are translating a poor quality metadata record -->
						<creator>
							<individualName>
								<surName>
									<xsl:value-of select="'unknown'"/>
								</surName>
							</individualName>
						</creator>
					</xsl:otherwise>
				</xsl:choose>
				<!-- added metadata provider check -->
				<xsl:if test="/metadata/metainfo/metc/cntinfo">
					<xsl:for-each select="/metadata/metainfo/metc/cntinfo">
						<metadataProvider>
							<xsl:for-each select="./cntorg">
								<organizationName>
									<xsl:value-of select="."/>
								</organizationName>
							</xsl:for-each>
							<xsl:if test="./cntorgp/cntper">
								<individualName>
									<surName>
										<xsl:value-of select="./cntorgp/cntper"/>
									</surName>
								</individualName>
								<xsl:for-each select="./cntorgpconta/cntorg">
									<organizationName>
										<xsl:value-of select="."/>
									</organizationName>
								</xsl:for-each>
							</xsl:if>
							<xsl:for-each select="./cntpos">
								<positionName>
									<xsl:value-of select="."/>
								</positionName>
							</xsl:for-each>
							<xsl:if test="./cntaddr!=''">
								<address>
									<deliveryPoint>
										<xsl:value-of select="./cntaddr/address"/>
									</deliveryPoint>
									<xsl:if test="./cntaddr/city!=''">
										<city>
											<xsl:value-of select="./cntaddr/city"/>
										</city>
									</xsl:if>
									<xsl:if test="./cntaddr/state!=''">
										<administrativeArea>
											<xsl:value-of select="./cntaddr/state"/>
										</administrativeArea>
									</xsl:if>
									<xsl:if test="./cntaddr/postal!=''">
										<postalCode>
											<xsl:value-of select="./cntaddr/postal"/>
										</postalCode>
									</xsl:if>
									<xsl:if test="./cntaddr/country!=''">
										<country>
											<xsl:value-of select="./cntaddr/country"/>
										</country>
									</xsl:if>
								</address>
							</xsl:if>
							<xsl:if test="./cntvoice!=''">
								<xsl:for-each select="./cntvoice">
									<phone>
										<xsl:attribute name="phonetype">
											<xsl:value-of select="'voice'"/>
										</xsl:attribute>
										<xsl:value-of select="."/>
									</phone>
								</xsl:for-each>
							</xsl:if>
							<xsl:if test="./cntemail!=''">
								<xsl:for-each select="./cntemail">
									<electronicMailAddress>
										<xsl:value-of select="."/>
									</electronicMailAddress>
								</xsl:for-each>
							</xsl:if>
						</metadataProvider>
					</xsl:for-each>
				</xsl:if>
				<xsl:if test="metadata/idinfo/citation/citeinfo/pubdate!=''">
					<pubDate>
						<xsl:value-of select="metadata/idinfo/citation/citeinfo/pubdate"/>
					</pubDate>
				</xsl:if>
				<xsl:if test="metadata/idinfo/descript/langdata">
					<language>
						<xsl:value-of select="metadata/idinfo/descript/langdata"/>
					</language>
				</xsl:if>
				<xsl:if test="metadata/idinfo/citation/citeinfo/serinfo/sername">
					<series>
						<xsl:value-of select="metadata/idinfo/citation/citeinfo/serinfo/sername"/>
					</series>
				</xsl:if>
				<xsl:if test="metadata/idinfo/descript/abstract">
					<abstract>
						<para>

							<xsl:value-of select="metadata/idinfo/descript/abstract"/>
							<!--the next paragraph is optional.  It will be added to the end of your abstract. Comment it out if you don't want it, or edit away -->
							Note: Complete metadata is available within the download file. This metadata can be viewed with
							esri ArcGIS software or by viewing the imbedded .xml file.  Coverages and grids contain a file called metadata.xml
							and shapefiles contain a file called  (shapefile_name.xml).  These files can be exported to FGDC and ISO metadata formats.
						</para>
					</abstract>
				</xsl:if>
				<xsl:if test="metadata/idinfo/keywords/theme/themekey!=''">
					<!-- even though these keywords are mandatory, ill check for content, anyway -->
					<keywordSet>
						<xsl:for-each select="metadata/idinfo/keywords/theme/themekey">
							<!-- theme kywds are mandatory, but the rest are optional, we'll put an if clause before print -->
							<keyword>
								<xsl:attribute name="keywordType">
									<xsl:value-of select="'theme'"/>
								</xsl:attribute>
								<xsl:value-of select="."/>
							</keyword>
						</xsl:for-each>
						<xsl:if test="metadata/idinfo/keywords/theme/themekt!=''">
							<keywordThesaurus>
								<xsl:value-of select="metadata/idinfo/keywords/theme/themekt"/>
							</keywordThesaurus>
						</xsl:if>
					</keywordSet>
				</xsl:if>
				<xsl:if test="metadata/dataqual/lineage/method/methodid/methkey">
					<keywordSet>
						<xsl:for-each select="metadata/dataqual/lineage/method/methodid/methkey">
							<keyword>
								<xsl:attribute name="keywordType">
									<xsl:value-of select="'theme'"/>
								</xsl:attribute>
								<xsl:value-of select="dataqual/lineage/method/methodid/methkey"/>
							</keyword>
						</xsl:for-each>
						<xsl:if test="metadata/dataqual/lineage/method/methodid/methkt!=''">
							<keywordThesaurus>
								<xsl:value-of
									select="metadata/dataqual/lineage/method/methodid/methkt"/>
							</keywordThesaurus>
						</xsl:if>
					</keywordSet>
				</xsl:if>
				<xsl:if test="metadata/idinfo/keywords/place/placekey!=''">
					<keywordSet>
						<xsl:for-each select="metadata/idinfo/keywords/place/placekey">
							<keyword>
								<xsl:attribute name="keywordType">
									<xsl:value-of select="'place'"/>
								</xsl:attribute>
								<xsl:value-of select="."/>
							</keyword>
						</xsl:for-each>
						<xsl:if test="metadata/idinfo/keywords/place/placekt!=''">
							<keywordThesaurus>
								<xsl:value-of select="metadata/idinfo/keywords/place/placekt"/>
							</keywordThesaurus>
						</xsl:if>
					</keywordSet>
				</xsl:if>
				<xsl:if test="metadata/idinfo/keywords/stratum/stratkey!=''">
					<keywordSet>
						<xsl:for-each select="metadata/idinfo/keywords/stratum/stratkey">
							<keyword>
								<xsl:attribute name="keywordType">
									<xsl:value-of select="'stratum'"/>
								</xsl:attribute>
								<xsl:value-of select="."/>
							</keyword>
						</xsl:for-each>
						<xsl:if test="metadata/idinfo/keywords/stratum/stratkt!=''">
							<keywordThesaurus>
								<xsl:value-of select="metadata/idinfo/keywords/stratum/stratkt"/>
							</keywordThesaurus>
						</xsl:if>
					</keywordSet>
				</xsl:if>
				<xsl:if test="metadata/idinfo/keywords/temporal/tempkey!=''">
					<keywordSet>
						<xsl:for-each select="metadata/idinfo/keywords/temporal/tempkey">
							<keyword>
								<xsl:attribute name="keywordType">
									<xsl:value-of select="'temporal'"/>
								</xsl:attribute>
								<xsl:value-of select="."/>
							</keyword>
						</xsl:for-each>
						<xsl:if test="metadata/idinfo/keywords/temporal/tempkt!=''">
							<keywordThesaurus>
								<xsl:value-of select="metadata/idinfo/keywords/temporal/tempkt"/>
							</keywordThesaurus>
						</xsl:if>
					</keywordSet>
				</xsl:if>
				<xsl:if test="metadata/idinfo/taxonomy/keywtax/taxonkey!=''">
					<keywordSet>
						<!-- this is mandatory if applicable, im adding a check before attempting to force output -->
						<xsl:for-each select="metadata/idinfo/taxonomy/keywtax/taxonkey">
							<!--sometimes, there are malformed FGDC, missing some intermidiate tags-->
							<keyword>
								<xsl:attribute name="keywordType">
									<xsl:value-of select="'taxonomic'"/>
								</xsl:attribute>
								<xsl:value-of select="."/>
							</keyword>
						</xsl:for-each>
						<xsl:if test="metadata/idinfo/taxonomy/keywtax/taxonkt!=''">
							<keywordThesaurus>
								<xsl:value-of select="metadata/idinfo/taxonomy/keywtax/taxonkt"/>
							</keywordThesaurus>
						</xsl:if>
					</keywordSet>
				</xsl:if>
				<xsl:if
					test="(metadata/idinfo/citation/citeinfo/edition!='') or (metadata/idinfo/citation/citeinfo/geoform!='') or (metadata/idinfo/citation/citeinfo/serinfo/sername!='') or (metadata/idinfo/citation/citeinfo/othercit!='') or (metadata/idinfo/descript/supplinf!='') or (metadata/idinfo/browse/browsen!='') or (metadata/eainfo/detailed/attr/attrdomv/rdom!='')">
					<additionalInfo>
						<xsl:if test="metadata/idinfo/citation/citeinfo/edition!=''">
							<!--edition optional -->
							<section>
								<title>
									<xsl:value-of select="'Edition: Version of title'"/>
								</title>
								<para>

									<xsl:value-of select="metadata/idinfo/citation/citeinfo/edition"/>

								</para>
							</section>
						</xsl:if>
						<xsl:if test="metadata/idinfo/citation/citeinfo/geoform!=''">
							<!-- geoform optional -->
							<section>
								<title>
									<xsl:value-of select="'Data presentation form'"/>
								</title>
								<para>

									<xsl:value-of select="metadata/idinfo/citation/citeinfo/geoform"/>

								</para>
							</section>
						</xsl:if>
						<xsl:if test="metadata/idinfo/citation/citeinfo/serinfo/sername!=''">
							<section>
								<title>
									<xsl:value-of
										select="'Series publication Identification and issue'"/>
								</title>
								<para>

									<xsl:value-of
										select="metadata/idinfo/citation/citeinfo/serinfo/sername"/>


									<xsl:value-of
										select="metadata/idinfo/citation/citeinfo/serinfo/issue"/>

								</para>
							</section>
						</xsl:if>
						<xsl:if test="metadata/idinfo/citation/citeinfo/othercit!=''">
							<section>
								<title>
									<xsl:value-of select="'Other citation details'"/>
								</title>
								<para>

									<xsl:value-of
										select="metadata/idinfo/citation/citeinfo/othercit"/>

								</para>
							</section>
						</xsl:if>
						<xsl:if test="metadata/idinfo/descript/supplinf!=''">
							<section>
								<title>
									<xsl:value-of
										select="'Other descriptive Information about the data set'"
									/>
								</title>
								<para>

									<xsl:value-of select="metadata/idinfo/descript/supplinf"/>

								</para>
							</section>
						</xsl:if>
						<xsl:if test="metadata/idinfo/browse/browsen!=''">
							<xsl:for-each select="metadata/idinfo/browse">
								<section>
									<title>
										<xsl:value-of select="'Browse Graphic'"/>
									</title>
									<xsl:if test="browsen">
										<section>
											<title>
												<xsl:value-of select="'Browse Graphic File Name'"/>
											</title>
											<para>

												<xsl:value-of select="browsen"/>

											</para>
										</section>
									</xsl:if>
									<xsl:if test="browsed">
										<section>
											<title>
												<xsl:value-of
												select="'Browse Graphic File Description'"/>
											</title>
											<para>

												<xsl:value-of select="browsed"/>

											</para>
										</section>
									</xsl:if>
									<xsl:if test="browset">
										<section>
											<title>
												<xsl:value-of select="'Browse Graphic File Type'"/>
											</title>
											<para>

												<xsl:value-of select="browset"/>

											</para>
										</section>
									</xsl:if>
								</section>
							</xsl:for-each>
						</xsl:if>
						<xsl:if test="metadata/eainfo/detailed/attr/attrdomv/rdom!=''">
							<section>
								<title>
									<xsl:value-of
										select="metadata/eainfo/detailed/attr/attrdomv/rdom/attrunit"
									/>
								</title>
								<para>

									<xsl:value-of select="././attrvai/attrva"/>

								</para>
							</section>
						</xsl:if>
					</additionalInfo>
				</xsl:if>
				<xsl:choose>
					<xsl:when
						test="(metadata/idinfo/accconst!='') or (metadata/idinfo/useconst!='') or (metadata/idinfo/secinfo/secsys!='') or (metadata/distinfo/disliab!='')">
						<intellectualRights>
							<section>
								<title>
									<xsl:value-of select="'Access constraints'"/>
								</title>
								<para>

									<xsl:value-of select="metadata/idinfo/accconst"/>
									<!-- mandatory in BDP, only once per doc -->

								</para>
							</section>
							<xsl:if test="metadata/idinfo/useconst!=''">
								<section>
									<title>
										<xsl:value-of select="'Use Constraints'"/>
									</title>
									<para>

										<xsl:value-of select="metadata/idinfo/useconst"/>

									</para>
								</section>
							</xsl:if>
							<xsl:if test="metadata/idinfo/secinfo/secsys!=''">
								<!-- optional in BDP, check first -->
								<section>
									<title>
										<xsl:value-of select="'Security Classification'"/>
									</title>
									<para>

										<xsl:value-of select="metadata/idinfo/secinfo/secsys"/>

									</para>
									<para>

										<xsl:value-of select="metadata/idinfo/secinfo/secclass"/>

									</para>
									<para>

										<xsl:value-of select="metadata/idinfo/secinfo/sechandl"/>

									</para>
								</section>
							</xsl:if>
							<xsl:if test="metadata/distinfo/disliab!=''">
								<section>
									<title>
										<xsl:value-of select="'Distribution Liability'"/>
									</title>
									<para>
										<xsl:for-each select="metadata/distinfo">

											<xsl:value-of select="distliab"/>

										</xsl:for-each>
									</para>
								</section>
							</xsl:if>
							<xsl:if test="metadata/idinfo/datacred!=''">
								<section>
									<title>Data Credit</title>
									<para>
										<xsl:value-of select="metadata/idinfo/datacred"/>
									</para>
								</section>
							</xsl:if>
						</intellectualRights>
					</xsl:when>
					<xsl:otherwise>
						<!-- 
          
                You may want to enter here eihter your Site "Data Policies" or the "Network Data Policies".

			    If you want to use the core (I.e; reduced)  official LTER Network Data Policies, just  Uncomment / Integrate the next section
		       that is enclosed by the %%% characters

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                -->
						<intellectualRights>
							<section>
								<title>LTER Network Data Access Requirements</title>
								<para> The access to all LTER data is subject to requirements set
									forth by this policy document to enable data providers to track
									usage, evaluate its impact in the community, and confirm users'
									acceptance of the terms of acceptable use. These requirements
									are standardized across the LTER Network to provide contractual
									exchange of data between Site Data Providers, Network Data
									Providers, and Data Users that can be encoded into electronic
									form and exchanged between computers. This will allow direct
									access to data via a common portal once these requirements have
									been fulfilled. The following information may be required
									directly or by proxy prior to the transference of any data
									object: <itemizedlist>
										<listitem>
											<para> Registration </para>
										</listitem>
										<listitem>
											<itemizedlist>
												<listitem>
												<para> Name </para>
												</listitem>
												<listitem>
												<para> Affiliation </para>
												</listitem>
												<listitem>
												<para> Email address </para>
												</listitem>
												<listitem>
												<para> Full Contact Info </para>
												</listitem>
											</itemizedlist>
										</listitem>
										<listitem>
											<para> Acceptance of the General Public Use Agreement or
												Restricted Data Use Agreement, as applicable </para>
										</listitem>
										<listitem>
											<para> A Statement of Intended Use that is compliant
												with the above agreements. Such statements may be
												made submitted explicitly or made implicitly via the
												data access portal interface. </para>
										</listitem>
									</itemizedlist>
								</para>
							</section>
							<section>
								<title>Conditions of Data Use</title>
								<para> The re-use of scientific data has the potential to greatly
									increase communication, collaboration and synthesis within and
									among disciplines, and thus is fostered, supported and
									encouraged. Permission to use this dataset is granted to the
									Data User free of charge subject to the following terms: <itemizedlist>
										<listitem>
											<para> Acceptable Use. Use of the dataset will be
												restricted to academic, research, educational,
												government, recreational, or other not-for-profit
												professional purposes. The Data User is permitted to
												produce and distribute derived works from this
												dataset provided that they are released under the
												same license terms as those accompanying this Data
												Set. Any other uses for the Data Set or its derived
												products will require explicit permission from the
												dataset owner. </para>
										</listitem>
										<listitem>
											<para> Redistribution. The data are provided for use by
												the Data User. The metadata and this license must
												accompany all copies made and be available to all
												users of this Data Set. The Data User will not
												redistribute the original Data Set beyond this
												collaboration sphere. </para>
										</listitem>
										<listitem>
											<para> Citation. It is considered a matter of
												professional ethics to acknowledge the work of other
												scientists. Thus, the Data User will properly cite
												the Data Set in any publications or in the metadata
												of any derived data products that were produced
												using the Data Set. Citation should take the
												following general form: Creator, Year of Data
												Publication, Title of Dataset, Publisher, Dataset
												identifier. </para>
										</listitem>
										<listitem>
											<para> Acknowledgement. The Data User should acknowledge
												any institutional support or specific funding awards
												referenced in the metadata accompanying this dataset
												in any publications where the Data Set contributed
												significantly to its content. Acknowledgements
												should identify the supporting party, the party that
												received the support, and any identifying
												information such as grant numbers. </para>
										</listitem>
										<listitem>
											<para> Notification. The Data User will notify the Data
												Set Contact when any derivative work or publication
												based on or derived from the Data Set is
												distributed. The Data User will provide the data
												contact with two reprints of any publications
												resulting from use of the Data Set and will provide
												copies, or on-line access to, any derived digital
												products. Notification will include an explanation
												of how the Data Set was used to produce the derived
												work. </para>
										</listitem>
										<listitem>
											<para> Collaboration. The Data Set has been released in
												the spirit of open scientific collaboration. Data
												Users are thus strongly encouraged to consider
												consultation, collaboration and/or co-authorship
												with the Data Set Creator. </para>
										</listitem>
									</itemizedlist> By accepting this Data Set, the Data User agrees
									to abide by the terms of this agreement. The Data Owner shall
									have the right to terminate this agreement immediately by
									written notice upon the Data User's breach of, or non-compliance
									with, any of its terms. The Data User may be held responsible
									for any misuse that is caused or encouraged by the Data User's
									failure to abide by the terms of this agreement. </para>
							</section>
							<section>
								<title>Disclaimer</title>
								<para> While substantial efforts are made to ensure the accuracy of
									data and documentation contained in this Data Set, complete
									accuracy of data and metadata cannot be guaranteed. All data and
									metadata are made available \"as is\". The Data User holds all
									parties involved in the production or distribution of the Data
									Set harmless for damages resulting from its use or
									interpretation. </para>
							</section>
							<xsl:if test="metadata/idinfo/datacred!=''">
								<section>
									<title>Data Credit</title>
									<para>
										<xsl:value-of select="metadata/idinfo/datacred"/>
									</para>
								</section>
							</xsl:if>
						</intellectualRights>
						<!--
             
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

			   Otherwise, the XSLT will attempt to encode any intellectual rights embedded in the original ESRI record as 'access and use constraints'
				 and security classifications.

				 Beware of the integration of BOTH the above-commented data policies and below translation of embedded policies. In EML we can
				only have one <intelRights> tag... you still can integrate both, but you'll need to tweak either this stylesheet, or to tweak the
				 resulting record.
                   -->
					</xsl:otherwise>
				</xsl:choose>
				<!-- distribution element -->
				<xsl:choose>
					<xsl:when
						test="metadata/distinfo/stdorder/digform/digtopt/onlinopt/computer/networka/networkr!=''">
						<xsl:for-each
							select="metadata/distinfo/stdorder/digform/digtopt/onlinopt/computer/networka/networkr">
							<distribution>
								<online>
									<url>
										<xsl:value-of select="."/>
									</url>
								</online>
							</distribution>
						</xsl:for-each>
					</xsl:when>
					<xsl:when test="metadata/distinfo/stdorder/digform/digtopt/offoptn/offmedia!=''">
						<xsl:for-each select="metadata/distinfo/stdorder/digform/digtopt/offoptn">
							<distribution>
								<offline>
									<mediumName>
										<xsl:value-of select="offmedia"/>
									</mediumName>
									<xsl:if test="reccap/recden!=''">
										<mediumDensity>
											<xsl:value-of select="reccap/recden"/>
										</mediumDensity>
									</xsl:if>
									<xsl:if test="reccap/recdenu!=''">
										<mediumDensityUnits>
											<xsl:value-of select="reccap/recdenu"/>
										</mediumDensityUnits>
									</xsl:if>
									<xsl:if test="recfmt!=''">
										<mediumFormat>
											<xsl:value-of select="recfmt"/>
										</mediumFormat>
									</xsl:if>
									<xsl:if test="compat!=''">
										<mediumNote>
											<xsl:value-of select="compat"/>
										</mediumNote>
									</xsl:if>
								</offline>
							</distribution>
						</xsl:for-each>
					</xsl:when>
					<xsl:when test="metadata/idinfo/citation/citeinfo/onlink!='' ">
						<xsl:for-each select="metadata/idinfo/citation/citeinfo/onlink">
							<distribution>
								<online>
									<url>
										<xsl:value-of select="."/>
									</url>
								</online>
							</distribution>
						</xsl:for-each>
					</xsl:when>
					<xsl:when test="metadata/idinfo/citation/citeinfo[starts-with(onlink,'Server')]">
						<distribution>
							<online>
								<connection>
									<connectionDefinition id="sde.connection1">
										<schemeName
											system="http://ces.asu.edu/eml/ces/connectionDictionary.xml"
											>Spatial Database Engine</schemeName>
										<description>Connection Definition for ESRI Spatial Database
											Engine.</description>
										<xsl:for-each
											select="/metadata/idinfo/citation/citeinfo/onlink">
											<parameterDefinition>
												<name>host</name>
												<description>Host name or ip number of the computer
												running the service.</description>
												<defaultValue>
												<xsl:value-of
												select="substring-before(substring-after(.,'Server='),';')"
												/>
												</defaultValue>
											</parameterDefinition>
											<parameterDefinition>
												<name>port</name>
												<description>The port number where the service is
												listening.</description>
												<defaultValue>
												<xsl:value-of
												select="substring-before(substring-after(.,'port:'),';')"
												/>
												</defaultValue>
											</parameterDefinition>
											<parameterDefinition>
												<name>catalog</name>
												<description>The name of the database or
												catalog.</description>
												<defaultValue>
												<xsl:value-of
												select="substring-before(substring-after(.,'Database='),';')"
												/>
												</defaultValue>
											</parameterDefinition>
											<parameterDefinition>
												<name>owner</name>
												<description>The owner or schema for the
												object</description>
											</parameterDefinition>
											<parameterDefinition>
												<name>object</name>
												<description>The name of the data
												object.</description>
											</parameterDefinition>
											<parameterDefinition>
												<name>shapeColumn</name>
												<description>The name of table column containing
												shape id.</description>
												<defaultValue>
												<xsl:value-of
												select="substring-before(substring-after(.,'User='),';')"
												/>
												</defaultValue>
											</parameterDefinition>
										</xsl:for-each>
									</connectionDefinition>
								</connection>
							</online>
						</distribution>
					</xsl:when>
				</xsl:choose>
				<coverage>
					<geographicCoverage>
						<!-- mandatory in FGDC: coordinates, however, we need a description-->
						<geographicDescription>
							<xsl:choose>
								<xsl:when test="metadata/idinfo/spdom/descgeog">
									<xsl:value-of select="metadata/idinfo/spdom/descgeog"/>
								</xsl:when>
								<xsl:when test="metadata/idinfo/keywords/place/placekey!=''">
									<xsl:for-each select="metadata/idinfo/keywords/place/placekey">
										<xsl:value-of select="."/>
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of
										select="'No geographic/area/plot description available. Sorry.'"
									/>
								</xsl:otherwise>
							</xsl:choose>
						</geographicDescription>
						<boundingCoordinates>
							<westBoundingCoordinate>
								<xsl:value-of select="metadata/idinfo/spdom/bounding/westbc"/>
							</westBoundingCoordinate>
							<eastBoundingCoordinate>
								<xsl:value-of select="metadata/idinfo/spdom/bounding/eastbc"/>
							</eastBoundingCoordinate>
							<northBoundingCoordinate>
								<xsl:value-of select="metadata/idinfo/spdom/bounding/northbc"/>
							</northBoundingCoordinate>
							<southBoundingCoordinate>
								<xsl:value-of select="metadata/idinfo/spdom/bounding/southbc"/>
							</southBoundingCoordinate>
							<xsl:if test="metadata/idinfo/spdom/bounding/boundalt/altmin!=''">
								<boundingAltitudes>
									<altitudeMinimum>
										<xsl:value-of
											select="metadata/idinfo/spdom/bounding/boundalt/altmin"
										/>
									</altitudeMinimum>
									<xsl:if
										test="metadata/idinfo/spdom/bounding/boundalt/altmax!=''">
										<altitudeMaximum>
											<xsl:value-of
												select="metadata/idinfo/spdom/bounding/boundalt/altmax"
											/>
										</altitudeMaximum>
									</xsl:if>
									<xsl:if
										test="metadata/idinfo/spdom/bounding/boundalt/altunits!=''">
										<altitudeUnits>
											<xsl:value-of
												select="metadata/idinfo/spdom/bounding/boundalt/altunits"
											/>
										</altitudeUnits>
									</xsl:if>
								</boundingAltitudes>
							</xsl:if>
						</boundingCoordinates>
						<xsl:for-each select="metadata/idinfo/spdom/dsgpoly">
							<datasetGPolygon>
								<!-- this section is pretty much a 1 to 1 correspondence (except syntaxis) between EML and BDP -->
								<datasetGPolygonOuterGRing>
									<xsl:for-each select="dsgpolyo/grngpoin">
										<!-- cardinality is 4 to infinity in BDP, and 3 to infinity in EML -->
										<gRingPoint>
											<gRingLatitude>
												<xsl:value-of select="gringlat"/>
											</gRingLatitude>
											<gRingLongitude>
												<xsl:value-of select="gringlon"/>
											</gRingLongitude>
										</gRingPoint>
									</xsl:for-each>
								</datasetGPolygonOuterGRing>
								<!-- exclusion ring optional in both standards -->
								<xsl:if test="dsgpolyx/grngpoin/gringlat!=''">
									<datasetGPolygonExclusionGRing>
										<xsl:for-each select="dsgpolyx/grngpoin">
											<gRingPoint>
												<gRingLatitude>
												<xsl:value-of select="gringlat"/>
												</gRingLatitude>
												<gRingLongitude>
												<xsl:value-of select="gringlon"/>
												</gRingLongitude>
											</gRingPoint>
										</xsl:for-each>
									</datasetGPolygonExclusionGRing>
								</xsl:if>
							</datasetGPolygon>
						</xsl:for-each>
					</geographicCoverage>
					<xsl:choose>
						<xsl:when test="metadata/idinfo/timeperd/timeinfo/sngdate/caldate!=''">
							<temporalCoverage>
								<singleDateTime>
									<!-- mandatory in BDP -->
									<calendarDate>
										<!--FGDC date example 19990429 -->
										<!-- defenitely, needs check ups-->
										<xsl:call-template name="FormatDate">
											<xsl:with-param name="DateTime">
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/sngdate/caldate"
												/>
											</xsl:with-param>
										</xsl:call-template>
										<!-- normalize date type routine call needed-->
									</calendarDate>
									<xsl:if
										test="metadata/idinfo/timeperd/timeinfo/sngdate/time!=''">
										<time>
											<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/sngdate/time"
											/>
										</time>
									</xsl:if>
								</singleDateTime>
							</temporalCoverage>
						</xsl:when>
						<xsl:when
							test="metadata/idinfo/timeperd/timeinfo/mdattim/sngdate/caldate!=''">
							<temporalCoverage>
								<xsl:for-each
									select="metadata/idinfo/timeperd/timeinfo/mdattim/sngdate">
									<singleDateTime>
										<calendarDate>
											<xsl:call-template name="FormatDate">
												<xsl:with-param name="DateTime">
												<xsl:value-of select="caldate"/>
												</xsl:with-param>
											</xsl:call-template>
											<!-- normalize date type routine call needed-->
										</calendarDate>
										<xsl:if test="time">
											<time>
												<xsl:value-of select="time"/>
											</time>
										</xsl:if>
									</singleDateTime>
								</xsl:for-each>
							</temporalCoverage>
						</xsl:when>
						<xsl:when
							test="metadata/idinfo/timeperd/timeinfo/sngdate/geolage/geolscal!=''">
							<temporalCoverage>
								<alternativeTimeScale>
									<timeScaleName>
										<xsl:value-of
											select="metadata/idinfo/timeperd/timeinfo/sngdate/geolage/geolscal"
										/>
									</timeScaleName>
									<timeScaleAgeEstimate>
										<xsl:value-of
											select="metadata/idinfo/timeperd/timeinfo/sngdate/geolage/geolest"
										/>
									</timeScaleAgeEstimate>
									<xsl:if
										test="metadata/idinfo/timeperd/timeinfo/sngdate/geolage/geolun!=''">
										<timeScaleAgeUncertainty>
											<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/sngdate/geolage/geolun"
											/>
										</timeScaleAgeUncertainty>
									</xsl:if>
									<xsl:if
										test="metadata/idinfo/timeperd/timeinfo/sngdate/geolage/geolexpl!=''">
										<timeScaleAgeExplanation>
											<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/sngdate/geolage/geolexpl"
											/>
										</timeScaleAgeExplanation>
									</xsl:if>
									<xsl:if
										test="metadata/idinfo/timeperd/timeinfo/sngdate/geolage/geolcit/citeinfo/title!=''">
										<timeScaleCitation>
											<title>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/sngdate/geolage/geolcit/citeinfo/title"
												/>
											</title>
											<creator>
												<!-- the perl code?-->
												<organizationName>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/sngdate/geolage/geolcit/citeinfo/origin"
												/>
												</organizationName>
											</creator>
											<pubDate>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/sngdate/geolage/geolcit/citeinfo/pubdate"
												/>
											</pubDate>
											<xsl:if
												test="metadata/idinfo/timeperd/timeinfo/sngdate/geolage/geolcit/citeinfo/serinfo/sername!=''">
												<series>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/sngdate/geolage/geolcit/citeinfo/serinfo/sername"
												/>
												</series>
											</xsl:if>
											<xsl:if
												test="metadata/idinfo/timeperd/timeinfo/sngdate/geolage/geolcit/citeinfo/onlink!=''">
												<distribution>
												<online>
												<url>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/sngdate/geolage/geolcit/citeinfo/onlink"
												/>
												</url>
												</online>
												</distribution>
											</xsl:if>
											<generic>
												<publisher>
												<!-- note: this is the only required element for the alternative time scale citation in EML. in BDP is mandatory if applicable, so default to creator value if that doesnt work -->
												<xsl:choose>
												<xsl:when
												test="metadata/idinfo/timeperd/timeinfo/sngdate/geolage/geolcit/citeinfo/pubinfo/pubplace!=''">
												<organizationName>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/sngdate/geolage/geolcit/citeinfo/pubinfo/pubplace"
												/>
												</organizationName>
												<xsl:if
												test="metadata/idinfo/timeperd/timeinfo/sngdate/geolage/geolcit/citeinfo/pubinfo/publish">
												<organizationName>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/sngdate/geolage/geolcit/citeinfo/pubinfo/publish"
												/>
												</organizationName>
												</xsl:if>
												</xsl:when>
												<xsl:otherwise>
												<organizationName>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/sngdate/geolage/geolcit/citeinfo/origin"
												/>
												</organizationName>
												</xsl:otherwise>
												</xsl:choose>
												</publisher>
												<xsl:if
												test="metadata/idinfo/timeperd/timeinfo/sngdate/geolage/geolcit/citeinfo/geoform!=''">
												<referenceType>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/sngdate/geolage/geolcit/citeinfo/geoform"
												/>
												</referenceType>
												</xsl:if>
												<xsl:if
												test="metadata/idinfo/timeperd/timeinfo/sngdate/geolage/geolcit/citeinfo/edition!=''">
												<edition>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/sngdate/geolage/geolcit/citeinfo/edition"
												/>
												</edition>
												</xsl:if>
											</generic>
										</timeScaleCitation>
									</xsl:if>
								</alternativeTimeScale>
							</temporalCoverage>
						</xsl:when>
						<xsl:when
							test="metadata/idinfo/timeperd/timeinfo/mdattim/sngdate/geolage/geolscal!=''">
							<xsl:for-each select="metadata/idinfo/timeperd/timeinfo/mdattim">
								<temporalCoverage>
									<alternativeTimeScale>
										<timeScaleName>
											<xsl:value-of select="sngdate/geolage/geolscal"/>
										</timeScaleName>
										<timeScaleAgeEstimate>
											<xsl:value-of select="sngdate/geolage/geolest"/>
										</timeScaleAgeEstimate>
										<xsl:if test="sngdate/geolage/geolun!=''">
											<timeScaleAgeUncertainty>
												<xsl:value-of select="sngdate/geolage/geolun"/>
											</timeScaleAgeUncertainty>
										</xsl:if>
										<xsl:if test="sngdate/geolage/geolexpl!=''">
											<timeScaleAgeExplanation>
												<xsl:value-of select="sngdate/geolage/geolexpl"/>
											</timeScaleAgeExplanation>
										</xsl:if>
										<xsl:if test="sngdate/geolage/geolcit/citeinfo/title!=''">
											<timeScaleCitation>
												<title>
												<xsl:value-of
												select="sngdate/geolage/geolcit/citeinfo/title"/>
												</title>
												<creator>
												<organizationName>
												<xsl:value-of
												select="sngdate/geolage/geolcit/citeinfo/origin"/>
												</organizationName>
												</creator>
												<pubDate>
												<xsl:value-of
												select="sngdate/geolage/geolcit/citeinfo/pubdate"
												/>
												</pubDate>
												<xsl:if
												test="sngdate/geolage/geolcit/citeinfo/serinfo/sername!=''">
												<series>
												<xsl:value-of
												select="sngdate/geolage/geolcit/citeinfo/serinfo/sername"
												/>
												</series>
												</xsl:if>
												<xsl:if
												test="sngdate/geolage/geolcit/citeinfo/onlink!=''">
												<distribution>
												<online>
												<url>
												<xsl:value-of
												select="sngdate/geolage/geolcit/citeinfo/onlink"/>
												</url>
												</online>
												</distribution>
												</xsl:if>
												<generic>
												<publisher>
												<xsl:choose>
												<xsl:when
												test="sngdate/geolage/geolcit/citeinfo/pubinfo/pubplace!=''">
												<organizationName>
												<xsl:value-of
												select="sngdate/geolage/geolcit/citeinfo/pubinfo/pubplace"
												/>
												</organizationName>
												</xsl:when>
												<xsl:when
												test="sngdate/geolage/geolcit/citeinfo/pubinfo/publish!=''">
												<organizationName>
												<xsl:value-of
												select="sngdate/geolage/geolcit/citeinfo/pubinfo/publish"
												/>
												</organizationName>
												</xsl:when>
												<xsl:otherwise>
												<organizationName>
												<xsl:value-of
												select="sngdate/geolage/geolcit/citeinfo/origin"/>
												</organizationName>
												</xsl:otherwise>
												</xsl:choose>
												</publisher>
												<xsl:if
												test="sngdate/geolage/geolcit/citeinfo/geoform!=''">
												<referenceType>
												<xsl:value-of
												select="sngdate/geolage/geolcit/citeinfo/geoform"
												/>
												</referenceType>
												</xsl:if>
												<xsl:if
												test="sngdate/geolage/geolcit/citeinfo/edition!=''">
												<edition>
												<xsl:value-of
												select="sngdate/geolage/geolcit/citeinfo/edition"
												/>
												</edition>
												</xsl:if>
												</generic>
											</timeScaleCitation>
										</xsl:if>
									</alternativeTimeScale>
								</temporalCoverage>
							</xsl:for-each>
						</xsl:when>
						<xsl:when test="metadata/idinfo/timeperd/timeinfo/rngdates/begdate!=''">
							<temporalCoverage>
								<rangeOfDates>
									<beginDate>
										<calendarDate>
											<xsl:call-template name="FormatDate">
												<xsl:with-param name="DateTime">
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/rngdates/begdate"
												/>
												</xsl:with-param>
											</xsl:call-template>
											<!-- normalize date type routine call needed-->
										</calendarDate>
										<xsl:if
											test="metadata/idinfo/timeperd/timeinfo/rngdates/begtime!=''">
											<time>
												<xsl:value-of select="."/>
											</time>
										</xsl:if>
									</beginDate>
									<endDate>
										<calendarDate>
											<xsl:call-template name="FormatDate">
												<xsl:with-param name="DateTime">
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/rngdates/enddate"
												/>
												</xsl:with-param>
											</xsl:call-template>
											<!-- normalize date type routine call neededFRequently is "present" "ongoing" and the like-->
										</calendarDate>
										<xsl:if
											test="metadata/idinfo/timeperd/timeinfo/rngdates/endtime!=''">
											<time>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/rngdates/endtime"
												/>
											</time>
										</xsl:if>
									</endDate>
								</rangeOfDates>
							</temporalCoverage>
						</xsl:when>
						<xsl:when
							test="metadata/idinfo/timeperd/timeinfo/rngdates/beggeol/geolage/geolscal!=''">
							<!-- it will get to this case when hell freezes over, but... -->
							<temporalCoverage>
								<rangeOfDates>
									<beginDate>
										<alternativeTimeScale>
											<timeScaleName>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/rngdates/beggeol/geolage/geolscal"
												/>
											</timeScaleName>
											<timeScaleAgeEstimate>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/rngdates/beggeol/geolage/geolest"
												/>
											</timeScaleAgeEstimate>
											<xsl:if
												test="metadata/idinfo/timeperd/timeinfo/rngdates/beggeol/geolage/geolun!=''">
												<timeScaleAgeUncertainty>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/rngdates/beggeol/geolage/geolun"
												/>
												</timeScaleAgeUncertainty>
											</xsl:if>
											<xsl:if
												test="metadata/idinfo/timeperd/timeinfo/rngdates/beggeol/geolage/geolexpl!=''">
												<timeScaleAgeExplanation>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/rngdates/beggeol/geolage/geolexpl"
												/>
												</timeScaleAgeExplanation>
											</xsl:if>
											<xsl:if
												test="metadata/idinfo/timeperd/timeinfo/rngdates/beggeol/geolage/geolcit/citeinfo/title">
												<timeScaleCitation>
												<title>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/rngdates/beggeol/geolage/geolcit/citeinfo/title"
												/>
												</title>
												<creator>
												<organizationName>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/rngdates/beggeol/geolage/geolcit/citeinfo/origin"
												/>
												</organizationName>
												</creator>
												<pubDate>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/rngdates/beggeol/geolage/geolcit/citeinfo/pubdate"
												/>
												</pubDate>
												<xsl:if
												test="metadata/idinfo/timeperd/timeinfo/rngdates/beggeol/geolage/geolcit/citeinfo/serinfo/sername!=''">
												<series>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/rngdates/beggeol/geolage/geolcit/citeinfo/serinfo/sername"
												/>
												</series>
												</xsl:if>
												<xsl:if
												test="metadata/idinfo/timeperd/timeinfo/rngdates/beggeol/geolage/geolcit/citeinfo/onlink!=''">
												<distribution>
												<online>
												<url>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/rngdates/beggeol/geolage/geolcit/citeinfo/onlink"
												/>
												</url>
												</online>
												</distribution>
												</xsl:if>
												<generic>
												<publisher>
												<organizationName>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/rngdates/beggeol/geolage/geolcit/citeinfo/pubinfo/publish"
												/>
												</organizationName>
												<organizationName>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/rngdates/beggeol/geolage/geolcit/citeinfo/pubinfo/pubplace"
												/>
												</organizationName>
												</publisher>
												<xsl:if
												test="metadata/idinfo/timeperd/timeinfo/rngdates/beggeol/geolage/geolcit/citeinfo/geoform!=''">
												<referenceType>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/rngdates/beggeol/geolage/geolcit/citeinfo/geoform"
												/>
												</referenceType>
												</xsl:if>
												<xsl:if
												test="metadata/idinfo/timeperd/timeinfo/rngdates/beggeol/geolage/geolcit/citeinfo/edition!=''">
												<edition>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/rngdates/beggeol/geolage/geolcit/citeinfo/edition"
												/>
												</edition>
												</xsl:if>
												</generic>
												</timeScaleCitation>
											</xsl:if>
										</alternativeTimeScale>
									</beginDate>
									<endDate>
										<alternativeTimeScale>
											<timeScaleName>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/rngdates/endgeol/geolage/geolscal"
												/>
											</timeScaleName>
											<timeScaleAgeEstimate>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/rngdates/endgeol/geolage/geolest"
												/>
											</timeScaleAgeEstimate>
											<xsl:if
												test="metadata/idinfo/timeperd/timeinfo/rngdates/endgeol/geolage/geolun!=''">
												<timeScaleAgeUncertainty>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/rngdates/endgeol/geolage/geolun"
												/>
												</timeScaleAgeUncertainty>
											</xsl:if>
											<xsl:if
												test="metadata/idinfo/timeperd/timeinfo/rngdates/endgeol/geolage/geolexpl!=''">
												<timeScaleAgeExplanation>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/rngdates/endgeol/geolage/geolexpl"
												/>
												</timeScaleAgeExplanation>
											</xsl:if>
											<xsl:if
												test="metadata/idinfo/timeperd/timeinfo/rngdates/endgeol/geolage/geolcit/citeinfo/title!=''">
												<timeScaleCitation>
												<title>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/rngdates/endgeol/geolage/geolcit/citeinfo/title"
												/>
												</title>
												<creator>
												<organizationName>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/rngdates/endgeol/geolage/geolcit/citeinfo/origin"
												/>
												</organizationName>
												</creator>
												<pubDate>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/rngdates/endgeol/geolage/geolcit/citeinfo/pubdate"
												/>
												</pubDate>
												<xsl:if
												test="metadata/idinfo/timeperd/timeinfo/rngdates/endgeol/geolage/geolcit/citeinfo/serinfo/sername!=''">
												<series>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/rngdates/endgeol/geolage/geolcit/citeinfo/serinfo/sername"
												/>
												</series>
												</xsl:if>
												<xsl:if
												test="metadata/idinfo/timeperd/timeinfo/rngdates/endgeol/geolage/geolcit/citeinfo/onlink!=''">
												<distribution>
												<online>
												<url>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/rngdates/endgeol/geolage/geolcit/citeinfo/onlink"
												/>
												</url>
												</online>
												</distribution>
												</xsl:if>
												<generic>
												<publisher>
												<organizationName>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/rngdates/endgeol/geolage/geolcit/citeinfo/pubinfo/publish"
												/>
												</organizationName>
												<organizationName>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/rngdates/endgeol/geolage/geolcit/citeinfo/pubinfo/pubplace"
												/>
												</organizationName>
												</publisher>
												<xsl:if
												test="metadata/idinfo/timeperd/timeinfo/rngdates/endgeol/geolage/geolcit/citeinfo/geoform!=''">
												<referenceType>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/rngdates/endgeol/geolage/geolcit/citeinfo/geoform"
												/>
												</referenceType>
												</xsl:if>
												<xsl:if
												test="metadata/idinfo/timeperd/timeinfo/rngdates/endgeol/geolage/geolcit/citeinfo/edition!=''">
												<edition>
												<xsl:value-of
												select="metadata/idinfo/timeperd/timeinfo/rngdates/endgeol/geolage/geolcit/citeinfo/edition"
												/>
												</edition>
												</xsl:if>
												</generic>
												</timeScaleCitation>
											</xsl:if>
										</alternativeTimeScale>
									</endDate>
								</rangeOfDates>
							</temporalCoverage>
						</xsl:when>
					</xsl:choose>
				</coverage>
				<xsl:if test="metadata/idinfo/descript/purpose!='' ">
					<xsl:for-each select="metadata/idinfo/descript/purpose">
						<purpose>
							<para>
								<xsl:value-of select="."/>
							</para>
						</purpose>
					</xsl:for-each>
				</xsl:if>
				<xsl:if test="metadata/idinfo/status/progress!=''">
					<maintenance>
						<!--this is mandatory in BDP , but I placed a conditional just in case-->
						<description>
							<section>
								<title>
									<xsl:value-of select="'Progress'"/>
								</title>
								<para>
									<xsl:for-each select="metadata/idinfo/status/progress">

										<xsl:value-of select="."/>

									</xsl:for-each>
								</para>
							</section>
							<section>
								<title>
									<xsl:value-of select="'Update'"/>
								</title>
								<para>
									<xsl:for-each select="metadata/idinfo/status/update">

										<xsl:value-of select="."/>

									</xsl:for-each>
								</para>
							</section>
						</description>
						<xsl:for-each select="metadata/idinfo/status/update">
							<!-- weak proposal here, should review: EML has enumerated fields -->
							<maintenanceUpdateFrequency>
								<xsl:value-of select="'otherMaintenancePeriod'"/>
							</maintenanceUpdateFrequency>
						</xsl:for-each>
					</maintenance>
				</xsl:if>
				<!--contact revisited in feb 07: EML needs one -->
				<xsl:choose>
					<xsl:when test="metadata/idinfo/ptcontac!='' ">
						<!-- it is really optional in fgdc/bdp.esri CHECK first-->
						<xsl:for-each select="metadata/idinfo/ptcontac">
							<contact>
								<xsl:if test="./cntinfo/cntorgp/cntper">
									<individualName>
										<surName>
											<xsl:value-of select="./cntinfo/cntorgp/cntper"/>
										</surName>
									</individualName>
									 <xsl:for-each select="./cntinfo/cntorgp/cntorg">
										<organizationName>
											<xsl:value-of select="."/>
										</organizationName>
										</xsl:for-each>
								</xsl:if>
								<xsl:for-each select="./cntinfo/cntpos">
									<positionName>
										<xsl:value-of select="."/>
									</positionName>
								</xsl:for-each>
								<xsl:if test="./cntinfo/cntaddr!=''">
									<address>
										<deliveryPoint>
											<xsl:value-of select="./cntinfo/cntaddr/address"/>
										</deliveryPoint>
										<xsl:if test="./cntinfo/cntaddr/city!=''">
											<city>
												<xsl:value-of select="./cntinfo/cntaddr/city"/>
											</city>
										</xsl:if>
										<xsl:if test="./cntinfo/cntaddr/state!=''">
											<administrativeArea>
												<xsl:value-of select="./cntinfo/cntaddr/state"/>
											</administrativeArea>
										</xsl:if>
										<xsl:if test="./cntinfo/cntaddr/postal!=''">
											<postalCode>
												<xsl:value-of select="./cntinfo/cntaddr/postal"/>
											</postalCode>
										</xsl:if>
										<xsl:if test="./cntinfo/cntaddr/country!=''">
											<country>
												<xsl:value-of select="./cntinfo/cntaddr/country"/>
											</country>
										</xsl:if>
									</address>
								</xsl:if>
								<xsl:if test="./cntinfo/cntvoice!=''">
									<xsl:for-each select="./cntinfo/cntvoice">
										<phone>
											<xsl:attribute name="phonetype">
												<xsl:value-of select="'voice'"/>
											</xsl:attribute>
											<xsl:value-of select="."/>
										</phone>
									</xsl:for-each>
								</xsl:if>
								<xsl:if test="./cntinfo/cntemail!=''">
									<xsl:for-each select="./cntinfo/cntemail">
										<electronicMailAddress>
											<xsl:value-of select="."/>
										</electronicMailAddress>
									</xsl:for-each>
								</xsl:if>
							</contact>
						</xsl:for-each>
					</xsl:when>
					<xsl:when test="metadata/distinfo/distrib/cntinfo!=''">
						<xsl:for-each select="metadata/distinfo/distrib/cntinfo">
							<contact>
								<xsl:for-each select="./cntorgp/cntper">
									<individualName>
										<surName>
											<xsl:value-of select="."/>
										</surName>
									</individualName>
								</xsl:for-each>
								<xsl:for-each select="./cntorgp/cntorg">
									<organizationName>
										<xsl:value-of select="."/>
									</organizationName>
								</xsl:for-each>
								<xsl:for-each select="./cntpos">
									<positionName>
										<xsl:value-of select="."/>
									</positionName>
								</xsl:for-each>
								<address>
									<xsl:for-each select="./cntaddr/address">
										<deliveryPoint>
											<xsl:value-of select="."/>
										</deliveryPoint>
									</xsl:for-each>
									<xsl:for-each select="./cntaddr/city">
										<city>
											<xsl:value-of select="."/>
										</city>
									</xsl:for-each>
									<xsl:for-each select="./cntaddr/state">
										<administrativeArea>
											<xsl:value-of select="."/>
										</administrativeArea>
									</xsl:for-each>
									<xsl:for-each select="./cntaddr/postal">
										<postalCode>
											<xsl:value-of select="."/>
										</postalCode>
									</xsl:for-each>
									<xsl:for-each select="./cntaddr/country">
										<country>
											<xsl:value-of select="."/>
										</country>
									</xsl:for-each>
								</address>
								<xsl:for-each select="./cntvoice">
									<phone phonetype="voice">
										<xsl:value-of select="."/>
									</phone>
								</xsl:for-each>
								<xsl:for-each select="./cntfax">
									<phone phonetype="fax">
										<xsl:value-of select="."/>
									</phone>
								</xsl:for-each>
								<xsl:for-each select="./cntemail">
									<electronicMailAddress>
										<xsl:value-of select="."/>
									</electronicMailAddress>
								</xsl:for-each>
							</contact>
						</xsl:for-each>
					</xsl:when>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="metadata/idinfo/citation/citeinfo/pubinfo/publish!=''">
						<!-- info gathered from ESRI doc -->
						<xsl:for-each select="metadata/idinfo/citation/citeinfo/pubinfo/publish">
							<publisher>
								<organizationName>
									<xsl:value-of select="."/>
								</organizationName>
							</publisher>
						</xsl:for-each>
					</xsl:when>
					<xsl:when test="metadata/publisher">
						<!-- this comes from the perl script aiding the transform -->
						<xsl:copy-of select="metadata/publisher"/>
					</xsl:when>
				</xsl:choose>
				<xsl:if test="metadata/idinfo/citation/citeinfo/pubinfo/pubplace!=''">
					<xsl:for-each select="metadata/idinfo/citation/citeinfo/pubinfo/pubplace">
						<pubPlace>
							<xsl:value-of select="."/>
						</pubPlace>
					</xsl:for-each>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="/metadata/spdoinfo/direct = 'Vector'">
						<spatialVector>
							<xsl:if test="metadata/eainfo/detailed/@Name!=''">
								<xsl:attribute name="id">
									<xsl:value-of select="metadata/eainfo/detailed/@Name"/>
								</xsl:attribute>
							</xsl:if>
							<xsl:if test="metadata/idinfo/citation/citeinfo/othercit!=''">
								<alternateIdentifier>
									<xsl:value-of select="metadata/idinfo/citation/citeinfo/othercit"
									/>
								</alternateIdentifier>
							</xsl:if>
							<entityName>
								<xsl:choose>
									<xsl:when test="metadata/eainfo/detailed/enttyp/enttypl!=''">
										<xsl:value-of
											select="metadata/eainfo/detailed/enttyp/enttypl"/>
									</xsl:when>
									<xsl:when test="metadata/eainfo/detailed/@Name!=''">
										<xsl:value-of select="metadata/eainfo/detailed/@Name"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="'Name of the resource not known'"/>
									</xsl:otherwise>
								</xsl:choose>
							</entityName>
							<entityDescription>
								<xsl:if test="metadata/idinfo/descript/abstract">
									<xsl:value-of select="metadata/idinfo/descript/abstract"/>
								</xsl:if>
							</entityDescription>
							<xsl:call-template name="physical"/>
							<xsl:call-template name="method"/>
							<xsl:call-template name="attr"/>
							<geometry>
								<xsl:choose>
									<xsl:when
										test="contains(metadata/spdoinfo/ptvctinf/sdtsterm/sdtstype,'string' )">
										<xsl:value-of select="'LineString'"/>
									</xsl:when>
									<xsl:when
										test="contains(metadata/spdoinfo/ptvctinf/sdtsterm/sdtstype,'ring' )">
										<xsl:value-of select="'LinearRing'"/>
									</xsl:when>
									<xsl:when
										test="contains(metadata/spdoinfo/ptvctinf/sdtsterm/sdtstype,'olygon') ">
										<xsl:value-of select="'Polygon'"/>
									</xsl:when>
									<xsl:when
										test="contains(metadata/spdoinfo/ptvctinf/sdtsterm/sdtstype,'chain' )">
										<xsl:value-of select="'Polygon'"/>
									</xsl:when>
									<xsl:when
										test="contains(metadata/spdoinfo/ptvctinf/sdtsterm/sdtstype,'point' )">
										<xsl:value-of select="'Point'"/>
									</xsl:when>
									<xsl:when
										test="contains(metadata/spdoinfo/ptvctinf/sdtsterm/sdtstype,'node' )">
										<xsl:value-of select="'Point'"/>
									</xsl:when>
									<xsl:when
										test="contains(metadata/spdoinfo/ptvctinf/sdtsterm/sdtstype,'link' )">
										<xsl:value-of select="'LinearRing'"/>
									</xsl:when>
									<xsl:when
										test="contains(metadata/spdoinfo/ptvctinf/sdtsterm/sdtstype,'pline') ">
										<!-- for Spline-->
										<xsl:value-of select="'Polygon'"/>
									</xsl:when>
									<xsl:when
										test="contains(metadata/spdoinfo/ptvctinf/sdtsterm/sdtstype,'arc' )">
										<xsl:value-of select="'Polygon'"/>
									</xsl:when>
									<xsl:when
										test="contains(metadata/spdoinfo/ptvctinf/sdtsterm/sdtstype,'ezier') ">
										<!-- for Bezier-->
										<xsl:value-of select="'Polygon'"/>
									</xsl:when>
									<xsl:when
										test="metadata/spdoinfo/ptvctinf/esriterm/efeageom/@code = '1'">
										<xsl:value-of select="'Point'"/>
									</xsl:when>
									<!-- not sure what Composite Object maps to in EML <xsl:when test="metadata/spdoinfo/ptvctinf/esriterm/efeageom/@code = '2'">
												<xsl:text>Composite object</xsl:text>
											</xsl:when>
										-->
									<xsl:when
										test="metadata/spdoinfo/ptvctinf/esriterm/efeageom/@code= '3'">
										<xsl:value-of select="'Line String'"/>
									</xsl:when>
									<xsl:when
										test="metadata/spdoinfo/ptvctinf/esriterm/efeageom/@code = '4'">
										<xsl:value-of select="'Polygon'"/>
									</xsl:when>
									<xsl:when
										test="metadata/spdoinfo/ptvctinf/esriterm/efeageom/@code = '5'">
										<xsl:value-of select="'Polygon'"/>
									</xsl:when>
									<xsl:when
										test="metadata/spdoinfo/ptvctinf/esriterm/efeageom/@code = '6'">
										<xsl:value-of select="'Polygon'"/>
									</xsl:when>
									<!-- not sure where it maps..<xsl:when test="metadata/spdoinfo/ptvctinf/esriterm/efeageom/@code = '9'">
										<xsl:text>Composite object</xsl:text>
											</xsl:when>-->
									<xsl:when
										test="metadata/spdoinfo/ptvctinf/esriterm/efeageom/@code = '11'">
										<xsl:value-of select="'Polygon'"/>
									</xsl:when>
									<xsl:when
										test="metadata/spdoinfo/ptvctinf/esriterm/efeageom/@code = '13'">
										<xsl:value-of select="'LineString'"/>
									</xsl:when>
									<xsl:when
										test="metadata/spdoinfo/ptvctinf/esriterm/efeageom/@code = '14'">
										<xsl:value-of select="'Polygon'"/>
									</xsl:when>
									<xsl:when
										test="metadata/spdoinfo/ptvctinf/esriterm/efeageom/@code= '15'">
										<xsl:value-of select="'Polygon'"/>
									</xsl:when>
									<xsl:when
										test="metadata/spdoinfo/ptvctinf/esriterm/efeageom/@code = '16'">
										<xsl:value-of select="'Polygon'"/>
									</xsl:when>
									<!--not sure again. <xsl:when test="metadata/spdoinfo/ptvctinf/esriterm/efeageom/@code = '18'">
											Composite object
									</xsl:when>
									<xsl:when test=". = '19'">
										<xsl:text>Composite object</xsl:text>
									</xsl:when>-->
									<xsl:when test=". = '20'">
										<xsl:value-of select="'LineString'"/>
									</xsl:when>
									<xsl:when
										test="metadata/spdoinfo/ptvctinf/esriterm/efeageom/@code = '22'">
										<xsl:value-of select="'Polygon'"/>
									</xsl:when>
								</xsl:choose>
							</geometry>
							<!-- cardinality in EML just 1 THIS needs to be address in next version of EML eml-2.0.X-->
							<!-- for now, we will put only the geometriObjectCount of the first object.. commenting the foreach-->
							<!-- <xsl:for-each select="metadata/spdoinfo/ptvctinf/sdtsterm/ptvctcnt">-->
							<xsl:choose>
								<xsl:when test="metadata/spdoinfo/ptvctinf/sdtsterm/ptvctcnt">
									<geometricObjectCount>
										<xsl:value-of
											select="metadata/spdoinfo/ptvctinf/sdtsterm/ptvctcnt"/>
									</geometricObjectCount>
								</xsl:when>
								<xsl:when test="metadata/spdoinfo/ptvctinf/esriterm/efeacnt">
									<geometricObjectCount>
										<xsl:value-of
											select="metadata/spdoinfo/ptvctinf/esriterm/efeacnt"/>
									</geometricObjectCount>
								</xsl:when>
							</xsl:choose>
							<xsl:call-template name="spref"/>
							<xsl:if test="/metadata/dataqual/posacc/horizpa/horizpar!=''">
								<xsl:call-template name="horizAccuracy"/>
							</xsl:if>
							<xsl:if test="/metadata/dataqual/posacc/vertacc">
								<xsl:call-template name="vertAccuracy"/>
							</xsl:if>
						</spatialVector>
					</xsl:when>
					<xsl:when test="metadata/spdoinfo/direct = 'Raster'">
						<spatialRaster>
							<xsl:if test="metadata/eainfo/detailed/@Name!=''">
								<xsl:attribute name="id">
									<xsl:value-of select="metadata/eainfo/detailed/@Name"/>
								</xsl:attribute>
							</xsl:if>
							<xsl:if test="metadata/idinfo/citation/citeinfo/othercit!=''">
								<alternateIdentifier>
									<xsl:value-of select="metadata/idinfo/citation/citeinfo/othercit"
									/>
								</alternateIdentifier>
							</xsl:if>
							<entityName>
								<xsl:choose>
									<xsl:when test="metadata/eainfo/detailed/@Name!=''">
										<xsl:value-of select="metadata/eainfo/detailed/@Name"/>
									</xsl:when>
									<xsl:when test="metadata/idinfo/citation/citeinfo/othercit!=''">
										<xsl:value-of
											select="metadata/idinfo/citation/citeinfo/othercit"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="'Name of the resource not known'"/>
									</xsl:otherwise>
								</xsl:choose>
							</entityName>
							<entityDescription>
								<xsl:if test="metadata/idinfo/descript/abstract!=''">
									<xsl:value-of select="metadata/idinfo/descript/abstract"
									> </xsl:value-of>
								</xsl:if>
							</entityDescription>
							<xsl:call-template name="physical"/>
							<xsl:call-template name="method"/>
							<xsl:call-template name="attr"/>
							<xsl:call-template name="spref"/>
							<xsl:if test="/metadata/spatRepInfo/Georect/cornerPts">
								<!-- may be able to map these to georeferenceInfo if we can see the full mapping
								<georeferenceInfo>
                                   <cornerPoint><xCoordinate></xCoordinate><yCoordinate></yCoordinate><pointInPixel></pointInPixel><corner></corner></cornerPoint>
								</georeferenceInfo>
                                 -->
							</xsl:if>
							<xsl:choose>
								<xsl:when test="/metadata/dataqual/posacc/horizpa/horizpar!=''">
									<xsl:call-template name="horizAccuracy"/>
								</xsl:when>
								<!-- may be found alternatively under metadata/esri/DataProperties... but cannot confirm.-->
								<xsl:otherwise>
									<horizontalAccuracy>
										<accuracyReport>
											<xsl:value-of
												select="'Horizontal Accuracy Report not present'"/>
										</accuracyReport>
									</horizontalAccuracy>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:choose>
								<xsl:when test="/metadata/dataqual/posacc/vertacc">
									<xsl:call-template name="vertAccuracy"/>
								</xsl:when>
								<xsl:otherwise>
									<verticalAccuracy>
										<accuracyReport>
											<xsl:value-of
												select="'Vertical Accuracy Report not present'"/>
										</accuracyReport>
									</verticalAccuracy>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:choose>
								<xsl:when test="/metadata/spdoinfo/rastinfo/xcellsize">
									<cellSizeXDirection>
										<xsl:value-of select="/metadata/spdoinfo/rastinfo/xcellsize"/>
									</cellSizeXDirection>
								</xsl:when>				
					            <xsl:otherwise>
						            <cellSizeXDirection>
							          <xsl:text>unknown</xsl:text>
						             </cellSizeXDirection>
					            </xsl:otherwise>
				           </xsl:choose>				
							<xsl:choose>
								<xsl:when test="/metadata/spdoinfo/rastinfo/ycellsize">
									<cellSizeYDirection>
										<xsl:value-of select="/metadata/spdoinfo/rastinfo/ycellsize"/>
									</cellSizeYDirection>
								</xsl:when>
								<xsl:otherwise>
									<cellSizeYDirection>
										<xsl:text>unknown</xsl:text>
									</cellSizeYDirection>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:choose>
								<xsl:when test="/metadata/spdoinfo/rastinfo/numbands">
									<numberOfBands>
										<xsl:value-of select="/metadata/spdoinfo/rastinfo/numbands"
										/>
									</numberOfBands>
								</xsl:when>
								<xsl:otherwise>
									<numberOfBands>
										<xsl:value-of select="'unknown'"/>
									</numberOfBands>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:choose>
								<xsl:when test="/metadata/spdoinfo/rastinfo/rastorig">
									<rasterOrigin>
										<xsl:value-of select="/metadata/spdoinfo/rastinfo/rastorig"
										/>
									</rasterOrigin>
								</xsl:when>
								<xsl:otherwise>
									<rasterOrigin>
										<xsl:value-of select="'Lower Left'"/>
										<!-- EML needs one ennumerated value  big assumption, chances are is already limping though-->
									</rasterOrigin>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:for-each select="/metadata/spdoinfo/rastinfo/rowcount">
								<rows>
									<xsl:value-of select="."/>
								</rows>
							</xsl:for-each>
							<xsl:for-each select="/metadata/spdoinfo/rastinfo/colcount">
								<columns>
									<xsl:value-of select="."/>
								</columns>
							</xsl:for-each>
							<xsl:choose>
								<xsl:when test="/metadata/spdoinfo/rastinfo/vrtcount">
									<verticals>
										<xsl:value-of select="/metadata/spdoinfo/rastinfo/vrtcount"
										/>
									</verticals>
								</xsl:when>
								<xsl:otherwise>
									<verticals>
										<xsl:value-of select="'unknown'"/>
									</verticals>
								</xsl:otherwise>
							</xsl:choose>
							<cellGeometry>
								<xsl:choose>
									<xsl:when
										test="/metadata/spdoinfo/rastinfo/rasttype ='Grid Cell'">
										<xsl:value-of select="'matrix'"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="'pixel'"/>
									</xsl:otherwise>
								</xsl:choose>
							</cellGeometry>
						</spatialRaster>
					</xsl:when>
				</xsl:choose>
			</dataset>
		</xsl:element>
	</xsl:template>
	<!-- 
		
		
		
		templates begin here -->
	<!-- 
		
		
		
		methods template -->
	<xsl:template name="method" match="/metadata/dataqual">
		<xsl:for-each select="/metadata/dataqual/lineage">
			<methods>
				<xsl:for-each select="procstep/procdesc">
					<methodStep>
						<description>
							<para>
								<xsl:value-of select="."/>
							</para>
						</description>

						<xsl:for-each select="procstep/srcused">
							<dataSource>
								<title>
									<xsl:value-of select="."/>
								</title>
							</dataSource>
						</xsl:for-each>
					</methodStep>
				</xsl:for-each>
			</methods>
		</xsl:for-each>
	</xsl:template>
	<!-- 
		
		
		
		
		attributeList template -->
	<xsl:template name="attr" match="/metadata/eainfo/detailed">
		<attributeList>
			<xsl:choose>
				<xsl:when test="/metadata/eainfo/detailed/attr">
					<xsl:for-each select="/metadata/eainfo/detailed/attr">
						<attribute>
							<xsl:attribute name="id">
								<xsl:value-of select="attrlabl"/>
							</xsl:attribute>
							<attributeName>
								<xsl:choose>
									<xsl:when test="./attrlabl">
										<xsl:value-of select="./attrlabl"/>
									</xsl:when>
									<xsl:when test="./attalias">
										<xsl:value-of select="./attalias"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="'Attribute name not provided'"/>
									</xsl:otherwise>
								</xsl:choose>
							</attributeName>
							<xsl:if test="./attalias">
								<!-- place the attribute alias, if any, on the EML attribute label. -->
								<attributeLabel>
									<xsl:value-of select="./attalias"/>
								</attributeLabel>
							</xsl:if>
							<xsl:choose>
								<xsl:when test="./attrdef">
									<attributeDefinition>
										<xsl:value-of select="./attrdef"/>
									</attributeDefinition>
								</xsl:when>
								<xsl:otherwise>
									<attributeDefinition>
										<xsl:value-of select="./attrlabl"/>
									</attributeDefinition>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:choose>
								<!-- storageSystem: not critical nowadays. -->
								<xsl:when test="attrtype='Number'">
									<xsl:choose>
										<xsl:when test="./atnumdec &gt; 1">
											<storageType
												typeSystem="http://www.w3.org/2001/XMLSchema-datatypes"
												>float</storageType>
										</xsl:when>
										<xsl:otherwise>
											<storageType
												typeSystem="http://www.w3.org/2001/XMLSchema-datatypes"
												>integer</storageType>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:when test="attrtype = 'String'">
									<storageType
										typeSystem="http://www.w3.org/2001/XMLSchema-datatypes"
										>string</storageType>
								</xsl:when>
								<xsl:otherwise>
									<storageType
										typeSystem="http://www.esri.com/metadata/esriprof80.html">
										<xsl:value-of select="./attrtype"/>
									</storageType>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:choose>
								<xsl:when test="./attrdomv">
									<xsl:choose>
										<xsl:when test="./attrdomv/edom">
											<!-- the attribute is an "enumerated domain", say nominal/nonNumericDomain/enumeratedDomain (or testDomain) -->
											<measurementScale>
												<nominal>
												<nonNumericDomain>
												<enumeratedDomain>
												<xsl:for-each select="./attrdomv/edom">
												<codeDefinition>
												<xsl:choose>
												<xsl:when test="./edomv">
												<code>
												<xsl:value-of select="./edomv"/>
												</code>
												</xsl:when>
												<xsl:otherwise>
												<code>
												<xsl:value-of select="'code not provided'"/>
												</code>
												</xsl:otherwise>
												</xsl:choose>
												<xsl:choose>
												<xsl:when test="./edomvd">
												<definition>
												<xsl:value-of select="./edomvd"/>
												</definition>
												</xsl:when>
												<xsl:otherwise>
												<definition>
												<xsl:value-of
												select="'code definition not provided'"/>
												</definition>
												</xsl:otherwise>
												</xsl:choose>
												<xsl:if test="./edomvds">
												<source>
												<xsl:value-of select="./edomvds"/>
												</source>
												</xsl:if>
												</codeDefinition>
												</xsl:for-each>
												</enumeratedDomain>
												</nonNumericDomain>
												</nominal>
											</measurementScale>
										</xsl:when>
										<xsl:when test="./attrdomv/rdom">
											<!-- it is a number, with units. however, units are optional in FGDC, offer a default if not provided.-->
											<measurementScale>
												<ratio>
												<unit>
												<!-- would be good to have a service to deal with the standard vs. custom unit.  At least we need to add routine for addntl metadata -->
												<customUnit>
												<xsl:choose>
												<xsl:when test="./attrdomv/rdom/attrunit">
												<xsl:value-of select="./attrdomv/rdom/attrunit"/>
												</xsl:when>
												<xsl:otherwise>
												<xsl:value-of
												select="'Unit Unknown or Not Reported'"/>
												</xsl:otherwise>
												</xsl:choose>
												</customUnit>
												</unit>
												<xsl:if test="./attrdomv/rdom/attrmres!=''">
												<precision>
												<xsl:value-of select="./attrdomv/rdom/attrmres"/>
												</precision>
												</xsl:if>
												<numericDomain>
												<numberType>
												<xsl:choose>
												<xsl:when test="./attrdomv/rdom/attrmres = 0"
												>whole</xsl:when>
												<xsl:when test="./attrdomv/rdom/attrmres = 1"
												>integer</xsl:when>
												<xsl:when test="./attrdomv/rdom/attrmres = 2"
												>natural</xsl:when>
												<xsl:when test="./attrdomv/rdom/attrmres = 3"
												>real</xsl:when>
												<xsl:otherwise>
												<xsl:value-of select="'real'"/>
												</xsl:otherwise>
												</xsl:choose>
												</numberType>

												<xsl:for-each select="./attrdomv/rdom/rdommin">
												<!-- bounds group has a 1-> \infinity cardinality in EML-->
												<bounds>
												<minimum exclusive="false">
												<xsl:value-of select="."/>
												</minimum>
												<xsl:if test="../rdommax!=''">
												<maximum exclusive="false">
												<xsl:value-of select="../rdommax"/>
												</maximum>
												</xsl:if>
												</bounds>
												</xsl:for-each>
												</numericDomain>
												</ratio>
											</measurementScale>
										</xsl:when>
										<xsl:when test="./attrdomv/codesetd">
											<measurementScale>
												<nominal>
												<nonNumericDomain>
												<enumeratedDomain>
												<externalCodeset>
												<codesetName>
												<xsl:value-of select="./attrdomv/codesetn"/>
												</codesetName>
												<citation>
												<title>
												<xsl:value-of
												select="'The External Codeset Source'"/>
												</title>
												<creator>
												<organizationName>
												<xsl:choose>
												<xsl:when test="./attrdomv/codesets!=''">
												<xsl:value-of select="./attrdomv/codesets"/>
												</xsl:when>
												<xsl:otherwise>
												<xsl:value-of
												select="'Unknown codeset citation source, or citation source not reported'"
												/>
												</xsl:otherwise>
												</xsl:choose>
												</organizationName>
												</creator>
												<generic>
												<publisher>
												<organizationName>
												<xsl:choose>
												<xsl:when test="./attrdomv/codesets!=''">
												<xsl:value-of select="./attrdomv/codesets"/>
												</xsl:when>
												<xsl:otherwise>
												<xsl:value-of
												select="'Unknown codeset citation publisher / source, or citation source not reported'"
												/>
												</xsl:otherwise>
												</xsl:choose>
												</organizationName>
												</publisher>
												</generic>
												</citation>
												</externalCodeset>
												</enumeratedDomain>
												</nonNumericDomain>
												</nominal>
											</measurementScale>
										</xsl:when>
										<xsl:when test="./attrdomv/udom">
											<measurementScale>
												<nominal>
												<nonNumericDomain>
												<textDomain>
												<definition>
												<xsl:choose>
												<xsl:when test="./attrdomv/udom!=''">
												<xsl:value-of select="./attrdomv/udom"/>
												</xsl:when>
												<xsl:otherwise>
												<xsl:value-of select="'Definition not provided'"/>
												</xsl:otherwise>
												</xsl:choose>
												</definition>
												</textDomain>
												</nonNumericDomain>
												</nominal>
											</measurementScale>
										</xsl:when>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<!-- inspite of being mandatory, this attribute was not documented to the domain level-->
									<measurementScale>
										<nominal>
											<nonNumericDomain>
												<textDomain>
												<definition>
												<xsl:value-of select="./attrdomv/attrdef"/>
												<xsl:if test="./attrdomv/attrtype">
												<xsl:value-of select="'    '"/>
												<xsl:value-of select="'Attribute Type : '"/>
												<xsl:value-of select="./attrdomv/attrtype"/>
												<xsl:value-of select="'    '"/>
												</xsl:if>
												<xsl:if test="./attrdomv/attwidth">
												<xsl:value-of select="'    '"/>
												<xsl:value-of select="'Attribute Width : '"/>
												<xsl:value-of select="./attrdomv/attwidth"/>
												<xsl:value-of select="'    '"/>
												</xsl:if>
												<xsl:if test="./attrdomv/atprecis">
												<xsl:value-of select="'    '"/>
												<xsl:value-of select="'Attribute Precision : '"/>
												<xsl:value-of select="./attrdomv/atprecis"/>
												<xsl:value-of select="'    '"/>
												</xsl:if>
												<xsl:if test="./attrdomv/attscale">
												<xsl:value-of select="'    '"/>
												<xsl:value-of select="'Attribute Scale : '"/>
												<xsl:value-of select="./attscale"/>
												<xsl:value-of select="'    '"/>
												</xsl:if>
												<xsl:value-of
												select="'No further information about this attribute was provided'"
												/>
												</definition>
												</textDomain>
											</nonNumericDomain>
										</nominal>
									</measurementScale>
								</xsl:otherwise>
							</xsl:choose>
							<!-- missing values are not encoded anywhere, only the BDP profile of FGDC CGDSM has something to that effect -->
							<xsl:if test="./attrvai/attrvae!=''">
								<!-- attribute accuracy report -->
								<accuracy>
									<attributeAccuracyReport>
										<xsl:value-of select="./attrvai/attrvae"/>
									</attributeAccuracyReport>
									<xsl:if test="./attrvai/attrva!=''">
										<quantitativeAttributeAccuracyAssessment>
											<attributeAccuracyValue>
												<xsl:value-of select="./attrvai/attrva"/>
											</attributeAccuracyValue>
											<attributeAccuracyExplanation>
												<xsl:value-of select="./attrvai/attrvae"/>
											</attributeAccuracyExplanation>
										</quantitativeAttributeAccuracyAssessment>
									</xsl:if>
								</accuracy>
							</xsl:if>
							<xsl:if test="./begdatea">
								<coverage>
									<temporalCoverage>
										<rangeOfDates>
											<beginDate>
												<calendarDate>
												<xsl:call-template name="FormatDate">
												<xsl:with-param name="DateTime">
												<xsl:value-of select="./begdatea"/>
												</xsl:with-param>
												</xsl:call-template>
												<!-- need to call the FormatDate template with arguments -->
												</calendarDate>
											</beginDate>
											<endDate>
												<calendarDate>
												<xsl:call-template name="FormatDate">
												<xsl:with-param name="DateTime">
												<xsl:value-of select="./enddatea"/>
												</xsl:with-param>
												</xsl:call-template>
												</calendarDate>
											</endDate>
										</rangeOfDates>
									</temporalCoverage>
								</coverage>
							</xsl:if>
							<xsl:for-each select="metadata/dataqual/attrac">
								<attributeAccuracy>
									<xsl:for-each select="./attraccr">
										<accuracyReport>
											<xsl:value-of select="."/>
										</accuracyReport>
									</xsl:for-each>
									<xsl:for-each select="qattrac">
										<quantitativeAccuracyReport>
											<xsl:for-each select="attracv">
												<attributeAccuracyValue>
												<xsl:value-of select="."/>
												</attributeAccuracyValue>
											</xsl:for-each>
											<xsl:for-each select="attrace">
												<attributeAccuracyMethod>
												<xsl:value-of select="."/>
												</attributeAccuracyMethod>
											</xsl:for-each>
										</quantitativeAccuracyReport>
									</xsl:for-each>
								</attributeAccuracy>
							</xsl:for-each>
						</attribute>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="/metadata/spdoinfo/rastinfo/rowcount">
					<attribute>
						<attributeName>Row Count</attributeName>
						<attributeLabel>rowcount</attributeLabel>
						<attributeDefinition>the maximum number of raster objects along the ordinate
							(y) axis. For use with rectangular raster objects</attributeDefinition>
						<measurementScale>
							<ratio>
								<unit>
									<standardUnit>
										<xsl:value-of select="'dimensionless'"/>
									</standardUnit>
								</unit>
								<numericDomain>
									<numberType>
										<xsl:value-of select="'integer'"/>
									</numberType>
								</numericDomain>
							</ratio>
						</measurementScale>
					</attribute>
					<xsl:if test="/metadata/spdoinfo/rastinfo/colcount">
						<attribute>
							<attributeName>Column Count</attributeName>
							<attributeLabel>colcount</attributeLabel>
							<attributeDefinition>the maximum number of raster objects along the
								abscissa (x) axis. For use with rectangular raster
								objects</attributeDefinition>
							<measurementScale>
								<ratio>
									<unit>
										<standardUnit>
											<xsl:value-of select="'dimensionless'"/>
										</standardUnit>
									</unit>
									<numericDomain>
										<numberType>
											<xsl:value-of select="'integer'"/>
										</numberType>
									</numericDomain>
								</ratio>
							</measurementScale>
						</attribute>
					</xsl:if>
				</xsl:when>
			</xsl:choose>
		</attributeList>
	</xsl:template>
	<!-- spatialReference template -->
	<xsl:template name="spref" match="/metadata/spref">
		<spatialReference>
			<xsl:choose>
				<xsl:when test="//spref/horizsys/cordsysn/projcsn">
					<horizCoordSysName>
						<xsl:value-of select="//spref/horizsys/cordsysn/projcsn"/>
					</horizCoordSysName>
				</xsl:when>
				<xsl:when test="//spref/horizsys/cordsysn/geogcsn">
					<horizCoordSysName>
						<xsl:value-of select="//spref/horizsys/cordsysn/geogcsn"/>
					</horizCoordSysName>
				</xsl:when>
				<xsl:when test="//spref/horizsys/geodetic/ellips!=''">
					<!-- at least, we may have a datum, and ellipsoid name and semiaxis. lets see . it turns out that most of the FGDC geospatial files will do this. instead of trying to come up with all the parameters, just populate what you can in this instance, starting by the good fact that we have the mandatory <geogCoordSys> info-->
					<xsl:element name="horizCoordSysDef">
						<xsl:attribute name="name">
							<xsl:choose>
								<xsl:when test="//spref/horizsys/planar/mapproj/mapprojn!=''">
									<xsl:value-of select="//spref/horizsys/planar/mapproj/mapprojn"
									/>
								</xsl:when>
								<xsl:when test="//spref/horizsys/planar/gridsys/gridsysn!=''">
									<xsl:value-of select="//spref/horizsys/planar/gridsys/gridsysn"
									/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="'Not able to determine'"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						<xsl:choose>
							<xsl:when test="//spref/horizsys/planar/mapproj/mapprojn!=''">
								<!-- dump both geog and proj. info in EML -->
								<xsl:element name="projCoordSys">
									<xsl:element name="geogCoordSys">
										<xsl:element name="datum">
											<xsl:attribute name="name">
												<xsl:choose>
												<!-- the datum name is optional in FGDC, but mandatory in EML201, EML210. check whether populated -->
												<xsl:when
												test="//spref/horizsys/geodetic/horizdn!=''">
												<xsl:value-of
												select="//spref/horizsys/geodetic/horizdn"/>
												</xsl:when>
												<xsl:otherwise>
												<xsl:value-of select="'Not able to determine'"/>
												</xsl:otherwise>
												</xsl:choose>
											</xsl:attribute>
										</xsl:element>
										<xsl:element name="spheroid">
											<xsl:attribute name="name">
												<xsl:value-of
												select="//spref/horizsys/geodetic/ellips"/>
											</xsl:attribute>
											<xsl:attribute name="semiAxisMajor">
												<xsl:value-of
												select="//spref/horizsys/geodetic/semiaxis"/>
											</xsl:attribute>
											<xsl:attribute name="denomFlatRatio">
												<xsl:value-of
												select="//spref/horizsys/geodetic/denflat"/>
											</xsl:attribute>
										</xsl:element>
										<xsl:element name="primeMeridian">
											<!-- except for the french and some pl. in asia, always greenwich. NEED to accom. those-->
											<xsl:attribute name="name">
												<xsl:value-of select="' Greenwich'"/>
											</xsl:attribute>
											<!-- harcoded -->
											<xsl:attribute name="longitude">
												<xsl:value-of select="'0.0'"/>
											</xsl:attribute>
										</xsl:element>
										<xsl:element name="unit">
											<!--again, except la galoise (radians) always degrees -->
											<xsl:attribute name="name">
												<xsl:value-of select="'degree'"/>
											</xsl:attribute>
										</xsl:element>
									</xsl:element>
									<xsl:element name="projection">
										<xsl:choose>
											<!-- begin multiple PARAMETER choice between possible FGDC projections -->
											<xsl:when
												test="//spref/horizsys/planar/mapproj/albers!=''">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Albers Conical Equal Area Section'"/>
												</xsl:attribute>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'Standard Parallel'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'Line of constant latitude at which the Earth and the plane intersect'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/albers/stdparll">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Longitude at central meridian'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'The line of logitude at the center of the map projection'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/albers/longcm">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Latitude of projection origin'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'The latitude chosen as center of the projection'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/albers/latprjo">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Easting'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/albers/feast">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Northing'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/albers/fnorth">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>

											</xsl:when>
											<xsl:when
												test="//spref/horizsys/planar/mapproj/azimequi/longcm!=''">
												<xsl:attribute name="name">
												<xsl:value-of select="'Azimuthal Equidistant '"/>
												</xsl:attribute>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Longitude at central meridian'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'The line of logitude at the center of the map projection'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/azimequi/longcm">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Latitude of projection origin'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'The latitude chosen as center of the projection'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/azimequi/latprjo">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Easting'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/azimequi/feast">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Northing'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="spref/horizsys/planar/mapproj/azimequi/fnorth">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>

											</xsl:when>
											<xsl:when
												test="//spref/horizsys/planar/mapproj/equicon/stdparll!=''">
												<xsl:attribute name="name">
												<xsl:value-of select="'Equidistant Conic '"/>
												</xsl:attribute>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'Standard Parallel'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'Line of constant latitude at which the Earth and the plane intersect'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/equicon/stdparll">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Longitude at central meridian'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'The line of logitude at the center of the map projection'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/equicon/longcm">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Latitude of projection origin'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'The latitude chosen as center of the projection'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/equicon/latprjo">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Easting'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/equicon/feast">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">

												<xsl:attribute name="name">
												<xsl:value-of select="'False Northing'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/equicon/fnorth">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>

											</xsl:when>
											<xsl:when
												test="//spref/horizsys/planar/mapproj/equirect/stdparll!=''">
												<xsl:attribute name="name">
												<xsl:value-of select="'Equirectangular'"/>
												</xsl:attribute>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'Standard Parallel'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'Line of constant latitude at which the Earth and the plane intersect'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/equirect/stdparll">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Longitude at central meridian'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'The line of logitude at the center of the map projection'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/equirect/longcm">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Easting'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/equirect/feast">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Northing'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/equirect/fnorth">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>

											</xsl:when>
											<xsl:when
												test="//spref/horizsys/planar/mapproj/gvnsp/heightpt!=''">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'General Vertical Near-Sided'"/>
												</xsl:attribute>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Height of Perspective Point Above Surface'"
												/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'height of viewpoint above the Earth, expressed in meters.'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/gvnsp/heightpt">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="' Longitude of Projection Center'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'longitude of the point of projection for azimuthal projections.'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/gvnsp/longpc">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Latitude of Projection Center'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="' latitude of the point of projection for azimuthal projections.'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/gvnsp/latprjc">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Easting'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/gvnsp/feast">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Northing'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/gvnsp/fnorth">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>

											</xsl:when>
											<xsl:when
												test="//spref/horizsys/planar/mapproj/gnomonic/longpc!=''">
												<xsl:attribute name="name">
												<xsl:value-of select="'Gnomonic'"/>
												</xsl:attribute>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="' Longitude of Projection Center'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'longitude of the point of projection for azimuthal projections.'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/gnomonic/longpc">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Latitude of Projection Center'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="' latitude of the point of projection for azimuthal projections.'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/gnomonic/latprjc">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Easting'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/gnomonic/feast">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Northing'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/gnomonic/fnorth">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>

											</xsl:when>
											<xsl:when
												test="//spref/horizsys/planar/mapproj/lamberta/longpc!=''">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Lambert Azimuthal Equal Area'"/>
												</xsl:attribute>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="' Longitude of Projection Center'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'longitude of the point of projection for azimuthal projections.'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/lamberta/longpc">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Latitude of Projection Center'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="' latitude of the point of projection for azimuthal projections.'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/lamberta/latprjc">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Easting'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/lamberta/feast">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Northing'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/lamberta/fnorth">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>

											</xsl:when>
											<xsl:when
												test="//spref/horizsys/planar/mapproj/lamberta/stdparll!=''">
												<xsl:attribute name="name">
												<xsl:value-of select="'Lambert Conformal Conic'"/>
												</xsl:attribute>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'Standard Parallel'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'Line of constant latitude at which the Earth and the plane intersect'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/lamberta/stdparll">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Longitude at central meridian'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'The line of logitude at the center of the map projection'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/lamberta/longcm">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Latitude of projection origin'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'The latitude chosen as center of the projection'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/lamberta/latprjo">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Easting'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/lamberta/feast">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Northing'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/lamberta/fnorth">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>

											</xsl:when>
											<xsl:when
												test="//spref/horizsys/planar/mapproj/mercator/stdparll!=''">
												<xsl:attribute name="name">
												<xsl:value-of select="'Mercator'"/>
												</xsl:attribute>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'Standard Parallel'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'Line of constant latitude at which the Earth and the plane intersect'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/mercator/stdparll">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'Scale factor at equator'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'a multiplier for reducing a distance obtained from a map by computation or scaling to the actual distance along the equator.'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/mercator/sfequat">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Longitude at central meridian'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'The line of logitude at the center of the map projection'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/mercator/longcm">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Northing'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/mercator/fnorth">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Easting'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/mercator/feast">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>

											</xsl:when>
											<xsl:when
												test="//spref/horizsys/planar/mapproj/modsak!=''">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Modified Stereographic for Alaska Projection'"
												/>
												</xsl:attribute>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Easting'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/modsak/feast">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Northing'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/modsak/fnorth">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>

											</xsl:when>
											<xsl:when
												test="//spref/horizsys/planar/mapproj/miller/longcm!=''">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Miller Cylindrical Projection'"/>
												</xsl:attribute>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Longitude at central meridian'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'The line of logitude at the center of the map projection'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/miller/longcm">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Easting'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/miller/feast">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Northing'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/miller/fnorth">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
											</xsl:when>
											<xsl:when
												test="//spref/horizsys/planar/mapproj/obqmerc/sfctrlin!=''">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Oblique Mercator Projection'"/>
												</xsl:attribute>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Scale factor at center line'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'a multiplier for reducing a distance obtained from a map by computation or scaling to the actual distance along the center line.'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/obqmerc/sfctrlin">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Oblique Line Azimuth: Azimuthal Angle'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'method used to describe the line along which an oblique mercator map projection is centered using the map projection origin and an azimuth. angle measured clockwise from north, and expressed in degrees.'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/obqmerc/obqlazim/azimangl">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Oblique Line Azimuth: Azimuthal Measure point longitude'"
												/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'method used to describe the line along which an oblique mercator map projection is centered using the map projection origin and an azimuth.  longitude of the map projection origin'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/obqmerc/obqlazim/azimptl">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Oblique Line Point: latitude'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'method used to describe the line along which an oblique mercator map projection is centered using two points near the limits of the mapped region that define the center line: latitude of a point defining the oblique line.'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/obqmerc/obqlpt/obqllat">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Oblique Line Point:  Longitude'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'method used to describe the line along which an oblique mercator map projection is centered using two points near the limits of the mapped region that define the center line. longitude of a point defining the oblique line.'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/obqmerc/obqlpt/obqllong">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Latitude of projection origin'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'The latitude chosen as center of the projection'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/obqmerc/latprjo">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Easting'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/obqmerc/feast">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Northing'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/obqmerc/fnorth">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
											</xsl:when>
											<xsl:when
												test="//spref/horizsys/planar/mapproj/orthogr/longpc!=''">
												<xsl:attribute name="name">
												<xsl:value-of select="'Orthographic'"/>
												</xsl:attribute>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="' Longitude of Projection Center'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'longitude of the point of projection for azimuthal projections.'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/orthogr/longpc">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Latitude of Projection Center'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="' latitude of the point of projection for azimuthal projections.'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/orthogr/latprjc">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Easting'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/orthogr/feast">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Northing'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/orthogr/fnorth">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
											</xsl:when>
											<xsl:when
												test="//spref/horizsys/planar/mapproj/polarst/svlong!=''">
												<xsl:attribute name="name">
												<xsl:value-of select="'Polar Stereographic'"/>
												</xsl:attribute>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Straight Vertical Longitude from Pole'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'longitude to be oriented straight up from the North or South Pole.'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/polarst/svlong">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'Standard Parallel'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'Line of constant latitude at which the Earth and the plane intersect'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/polarst/stdparll">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Scale factor at projection origin'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'a multiplier for reducing a distance obtained from a map by computation or scaling to the actual distance at the projection origin.'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/polarst/sfprjorg">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Easting'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/polarst/feast">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Northing'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/polarst/fnorth">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
											</xsl:when>
											<xsl:when
												test="//spref/horizsys/planar/mapproj/polycon/longcm!=''">
												<xsl:attribute name="name">
												<xsl:value-of select="'Polyconic'"/>
												</xsl:attribute>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Longitude at central meridian'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'The line of logitude at the center of the map projection'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/polycon/longcm">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Latitude of projection origin'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'The latitude chosen as center of the projection'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/polycon/latprjo">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Easting'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/polycon/feast">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Northing'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/polycon/fnorth">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
											</xsl:when>
											<xsl:when
												test="//spref/horizsys/planar/mapproj/robinson/longpc!=''">
												<xsl:attribute name="name">
												<xsl:value-of select="'Robinson'"/>
												</xsl:attribute>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="' Longitude of Projection Center'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'longitude of the point of projection for azimuthal projections.'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/robinson/longpc">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Easting'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/robinson/feast">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Northing'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/robinson/fnorth">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
											</xsl:when>
											<xsl:when
												test="//spref/horizsys/planar/mapproj/sinusoid/longcm!=''">
												<xsl:attribute name="name">
												<xsl:value-of select="'Sinusoidal'"/>
												</xsl:attribute>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Longitude at central meridian'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'The line of logitude at the center of the map projection'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/sinusoid/longcm">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Easting'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/sinusoid/feast">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Northing'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/sinusoid/fnorth">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
											</xsl:when>
											<xsl:when
												test="//spref/horizsys/planar/mapproj/spaceobq/landsat!=''">
												<xsl:attribute name="name">
												<xsl:value-of select="'Space Oblique Mercator'"/>
												</xsl:attribute>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'Landsat Number'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'number of the Landsat satellite. (Note: This data element exists solely to provide a parameter needed to define the space oblique mercator projection. It is not used to identify data originating from a remote sensing vehicle.)'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/spaceobq/landsat">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'Path Number'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'number of the orbit of the Landsat satellite. (Note: This data element exists solely to provide a parameter needed to define the space oblique mercator projection. It is not used to identify data originating from a remote sensing vehicle.)'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/spaceobq/pathnum">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Easting'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/spaceobq/feast">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Northing'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/spaceobq/fnorth">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
											</xsl:when>
											<xsl:when
												test="//spref/horizsys/planar/mapproj/stereo/longpc!=''">
												<xsl:attribute name="name">
												<xsl:value-of select="'Stereographic'"/>
												</xsl:attribute>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="' Longitude of Projection Center'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'longitude of the point of projection for azimuthal projections.'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/stereo/longpc">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Latitude of Projection Center'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="' latitude of the point of projection for azimuthal projections.'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/stereo/latprjc">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Easting'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/stereo/feast">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Northing'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/stereo/fnorth">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
											</xsl:when>
											<xsl:when
												test="//spref/horizsys/planar/mapproj/transmer/sfctrmer!=''">
												<xsl:attribute name="name">
												<xsl:value-of select="'Transverse Mercator'"/>
												</xsl:attribute>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Scale factor at central meridian'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'a multiplier for reducing a distance obtained from a map by computation or scaling to the actual distance along the central meridian.'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/transmer/sfctrmer">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Longitude at central meridian'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'The line of logitude at the center of the map projection'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/transmer/longcm">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Latitude of projection origin'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'The latitude chosen as center of the projection'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/transmer/latprjo">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Easting'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/transmer/feast">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Northing'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/transmer/fnorth">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>

											</xsl:when>
											<xsl:when
												test="//spref/horizsys/planar/mapproj/vdgrin/longcm!=''">
												<xsl:attribute name="name">
												<xsl:value-of select="'van der Grinten'"/>
												</xsl:attribute>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Longitude at central meridian'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'The line of logitude at the center of the map projection'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/vdgrin/longcm">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Easting'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/vdgrin/feast">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Northing'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/vdgrin/fnorth">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
											</xsl:when>
											<xsl:when
												test="//spref/horizsys/planar/mapproj/mapprojp!=''">
												<!-- this case is tricky, as it may have up to 6 of all the parameters mentioned before. NEED ifs..-->
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Other Set of  Map Projection Parameters'"
												/>
												</xsl:attribute>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'Standard Parallel'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'Line of constant latitude at which the Earth and the plane intersect'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/mapprojp/stdparll">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Longitude at central meridian'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'The line of logitude at the center of the map projection'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/mapprojp/longcm">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Latitude of projection origin'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'The latitude chosen as center of the projection'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/mapprojp/latprjo">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Easting'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/mapprojp/feast">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'False Northing'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'A value added in a rectangular coordinate system, usually used to avoid negative values'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/mapprojp/fnorth">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'Scale factor at equator'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'a multiplier for reducing a distance obtained from a map by computation or scaling to the actual distance along the equator.'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/mapprojp/sfequat">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Height of Perspective Point Above Surface'"
												/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'height of viewpoint above the Earth, expressed in meters.'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/mapprojp/heightpt">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="' Longitude of Projection Center'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'longitude of the point of projection for azimuthal projections.'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/mapprojp/longpc">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Latitude of Projection Center'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="' latitude of the point of projection for azimuthal projections.'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/mapprojp/latprjc">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Scale factor at center line'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'a multiplier for reducing a distance obtained from a map by computation or scaling to the actual distance along the center line.'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/mapprojp/sfctrlin">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Oblique Line Azimuth: Azimuthal Angle'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'method used to describe the line along which an oblique mercator map projection is centered using the map projection origin and an azimuth. angle measured clockwise from north, and expressed in degrees.'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/mapprojp/obqlazim/azimangl">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Oblique Line Azimuth: Azimuthal Measure point longitude'"
												/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'method used to describe the line along which an oblique mercator map projection is centered using the map projection origin and an azimuth.  longitude of the map projection origin'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/mapprojp/obqlazim/azimptl">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Oblique Line Point: latitude'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'method used to describe the line along which an oblique mercator map projection is centered using two points near the limits of the mapped region that define the center line: latitude of a point defining the oblique line.'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/mapprojp/obqlpt/obqllat">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Oblique Line Point:  Longitude'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'method used to describe the line along which an oblique mercator map projection is centered using two points near the limits of the mapped region that define the center line. longitude of a point defining the oblique line.'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/mapprojp/obqlpt/obqllong">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Straight Vertical Longitude from Pole'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'longitude to be oriented straight up from the North or South Pole.'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/mapprojp/svlong">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Scale factor at projection origin'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'a multiplier for reducing a distance obtained from a map by computation or scaling to the actual distance at the projection origin.'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/mapprojp/sfprjorg">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'Landsat Number'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'number of the Landsat satellite. (Note: This data element exists solely to provide a parameter needed to define the space oblique mercator projection. It is not used to identify data originating from a remote sensing vehicle.)'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/mapprojp/landsat">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of select="'Path Number'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'number of the orbit of the Landsat satellite. (Note: This data element exists solely to provide a parameter needed to define the space oblique mercator projection. It is not used to identify data originating from a remote sensing vehicle.)'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/mapprojp/pathnum">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Scale factor at central meridian'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'a multiplier for reducing a distance obtained from a map by computation or scaling to the actual distance along the central meridian.'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/mapprojp/sfctrmer">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
												<xsl:element name="parameter">
												<xsl:attribute name="name">
												<xsl:value-of
												select="'Other projection definitions'"/>
												</xsl:attribute>
												<xsl:attribute name="description">
												<xsl:value-of
												select="'a description of a projection, not defined elsewhere in the standard, that was used for the data set. The information provided shall include the name of the projection, names of parameters and values used for the data set, and the citation of the specification for the algorithms that describe the mathematical relationship between Earth and plane or developable surface for the projection.'"
												/>
												</xsl:attribute>
												<xsl:for-each
												select="//spref/horizsys/planar/mapproj/mapprojp/otherprj">
												<xsl:attribute name="value">
												<xsl:value-of select="."/>
												</xsl:attribute>
												</xsl:for-each>
												</xsl:element>
											</xsl:when>
										</xsl:choose>
										<!-- end of big long FGDC projection PARAMETERS choice -->
										<xsl:element name="unit">
											<!-- could be better, but in most cases this is a  'meter'.  In reality, this bears a lot of logic, coupled with the fact that it may not be in EMLs dictionary such parameter.-->
											<xsl:attribute name="name">
												<xsl:value-of select="'meter'"/>
											</xsl:attribute>
										</xsl:element>
									</xsl:element>
									<!--end of projection element -->
								</xsl:element>
								<!-- end of projCoordSys element -->
							</xsl:when>
							<xsl:when test="//spref/horizsys/geodetic">
								<!-- dump only geogCoordSys element -->
								<xsl:element name="geogCoordSys">
									<xsl:element name="datum">
										<xsl:attribute name="name">
											<xsl:choose>
												<!-- the datum name is optional in FGDC, but mandatory in EML201, 210. check whether populated -->
												<xsl:when
												test="//spref/horizsys/geodetic/horizdn!=''">
												<xsl:value-of
												select="//spref/horizsys/geodetic/horizdn"/>
												</xsl:when>
												<xsl:otherwise>
												<xsl:value-of select="'Not able to determine'"/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:attribute>
									</xsl:element>
									<xsl:element name="spheroid">
										<xsl:attribute name="name">
											<xsl:value-of select="//spref/horizsys/geodetic/ellips"
											/>
										</xsl:attribute>
										<xsl:attribute name="semiAxisMajor">
											<xsl:value-of
												select="//spref/horizsys/geodetic/semiaxis"/>
										</xsl:attribute>
										<xsl:attribute name="denomFlatRatio">
											<xsl:value-of select="//spref/horizsys/geodetic/denflat"
											/>
										</xsl:attribute>
									</xsl:element>
									<xsl:element name="primeMeridian">
										<!-- except for the french and some pl. in asia, always greenwich. NEED to accom. those-->
										<xsl:attribute name="name">
											<xsl:value-of select="' Greenwich'"/>
										</xsl:attribute>
										<!-- harcoded -->
										<xsl:attribute name="longitude">
											<xsl:value-of select="'0.0'"/>
										</xsl:attribute>
									</xsl:element>
									<xsl:element name="unit">
										<!--again, except la galoise (radians) always degrees -->
										<xsl:attribute name="name">
											<xsl:value-of select="'degree'"/>
										</xsl:attribute>
									</xsl:element>
								</xsl:element>
							</xsl:when>
							<!-- end of geogCoordSys and all tree..-->
						</xsl:choose>
						<!-- end of choice of "projection" vs. "geog" -->
					</xsl:element>
					<!--end of horizCoordSysDef -->
				</xsl:when>
				<xsl:when test="//spref/horizsys/planar/mapproj/mapprojn!=''">
					<!-- we may have a projection name -->
					<!-- we could have try to decode what datum and ellisoid we have, but it'd be too cumbersome.-->
					<horizCoordSysName>
						<xsl:value-of select="//spref/horizsys/planar/mapproj/mapprojn"/>
					</horizCoordSysName>
				</xsl:when>
				<!-- end of case no Geodetic info, but mapproj existed -->
				<xsl:when test="//spref/horizsys/planar/gridsys/gridsysn">
					<!-- we may have a gridsystem-->
					<!-- info for datum, etc, too dificult to guess -->
					<horizCoordSysName>
						<xsl:value-of select="//spref/horizsys/planar/gridsys/gridsysn"/>
					</horizCoordSysName>
				</xsl:when>
			</xsl:choose>
			<!-- time for testing whether there is vertical info, and if so, place it here. -->
			<xsl:if test="spref/vertdef/altsys/altdatum!=''">
				<!-- if true, we have at least the vertical coordinate altitude system 1-1 FGDC to EML -->
				<xsl:element name="vertCoordSys">
					<xsl:element name="altitudeSysDef">
						<xsl:for-each select="spref/vertdef/altsys/altdatum">
							<xsl:element name="altitudeDatumName">
								<xsl:value-of select="."/>
							</xsl:element>
						</xsl:for-each>
						<xsl:for-each select="spref/vertdef/altsys/altres">
							<xsl:element name="altitudeResolution">
								<xsl:value-of select="."/>
							</xsl:element>
						</xsl:for-each>
						<xsl:for-each select="spref/vertdef/altsys/altunits">
							<xsl:element name="altitudeDistanceUnits">
								<xsl:value-of select="."/>
							</xsl:element>
						</xsl:for-each>
						<xsl:for-each select="spref/vertdef/altsys/altenc">
							<xsl:element name="altitudeEncodingMethod">
								<xsl:value-of select="."/>
							</xsl:element>
						</xsl:for-each>
					</xsl:element>
					<xsl:if test="spref/vertdef/depthsys/depthdn!=''">
						<!-- if true, we also have the depth system for the vertical coordinates -->
						<xsl:element name="depthSysDef">
							<xsl:for-each select="spref/vertdef/depthsys/depthdn">
								<xsl:element name="depthDatumName">
									<xsl:value-of select="."/>
								</xsl:element>
							</xsl:for-each>
							<xsl:for-each select="spref/vertdef/depthsys/depthres">
								<xsl:element name="depthResolution">
									<xsl:value-of select="."/>
								</xsl:element>
							</xsl:for-each>
							<xsl:for-each select="spref/vertdef/depthsys/depthdu">
								<xsl:element name="depthDistanceUnits">
									<xsl:value-of select="."/>
								</xsl:element>
							</xsl:for-each>
							<xsl:for-each select="spref/vertdef/depthsys/depthem">
								<xsl:element name="depthEncodingMethod">
									<xsl:value-of select="."/>
								</xsl:element>
							</xsl:for-each>
						</xsl:element>
					</xsl:if>
				</xsl:element>
			</xsl:if>
			<!-- end fi for testing existence of vertical coordinate info -->
		</spatialReference>
	</xsl:template>
	<!-- vertical accuracy template -->
	<xsl:template name="vertAccuracy" match="/metadata/dataqual/posacc/vertacc">
		<verticalAccuracy>
			<xsl:for-each select="/metadata/dataqual/posacc/vertacc/vertaccr">
				<accuracyReport>
					<xsl:value-of select="."/>
				</accuracyReport>
			</xsl:for-each>
			<xsl:for-each select="/metadata/dataqual/posacc/vertacc/qvertpa">
				<quantitativeAccuracyReport>
					<xsl:for-each select="./vertaccv">
						<quantitativeAccuracyValue>
							<xsl:value-of select="."/>
						</quantitativeAccuracyValue>
					</xsl:for-each>
					<xsl:for-each select="./vertacce">
						<quantitativeAccuracyMethod>
							<xsl:value-of select="."/>
						</quantitativeAccuracyMethod>
					</xsl:for-each>
				</quantitativeAccuracyReport>
			</xsl:for-each>
		</verticalAccuracy>
	</xsl:template>
	<!-- horizontal accuracy template -->
	<xsl:template name="horizAccuracy" match="/metadata/dataqual/posacc/horizpa">
		<horizontalAccuracy>
			<xsl:for-each select="/metadata/dataqual/posacc/horizpa/horizpar">
				<accuracyReport>
					<xsl:value-of select="."/>
				</accuracyReport>
			</xsl:for-each>
			<xsl:for-each select="/metadata/dataqual/posacc/horizpa/qhorizpa">
				<quantitativeAccuracyReport>
					<xsl:for-each select="./horizpav">
						<quantitativeAccuracyValue>
							<xsl:value-of select="."/>
						</quantitativeAccuracyValue>
					</xsl:for-each>
					<xsl:for-each select="./horizpae">
						<quantitativeAccuracyMethod>
							<xsl:value-of select="."/>
						</quantitativeAccuracyMethod>
					</xsl:for-each>
				</quantitativeAccuracyReport>
			</xsl:for-each>
		</horizontalAccuracy>
	</xsl:template>
	<!-- 
		
		
		
		physical template -->
	<xsl:template name="physical" match="/metadata">
		<!-- in EML, we need at least the "objectName" (like a filename, or resource name) and either a formatName for the GIS app or several parameters of a raster file and/or the usual parameters needed to describe a text format: attribute orientation and field delimiter.  CHECK for content before embarking here-->
		<!-- first, let's check for filename -->
		<xsl:if
			test="(metadata/eainfo/detailed/enttyp/enttypl!='') or 
			(metadata/eainfo/detailed/@Name!='') or 
			( metadata/distinfo/resdesc!='')  ">
			<!-- now let's check for external format or other variants of possible dataFormats -->
			<xsl:if
				test="(//idinfo/natvform!='') or 
				(//idinfo/native!='') or 
				(//distributor/distorFormat/formatName!='') or 
				(metadata/distinfo/stdorder/digform/formName!='') or 
				(metadata/distinfo/stdorder/nondig!='')">
				<physical>
					<objectName>
						<xsl:choose>
							<xsl:when test="metadata/eainfo/detailed/enttyp/enttypl!=''">
								<xsl:value-of select="metadata/eainfo/detailed/enttyp/enttypl"/>
							</xsl:when>
							<xsl:when test="metadata/idinfo/citation/citeinfo/onlink !=''">
								<xsl:value-of select="metadata/idinfo/citation/citeinfo/onlink"/>
							</xsl:when>
							<xsl:when test="metadata/eainfo/detailed/@Name!=''">
								<xsl:value-of select="metadata/eainfo/detailed/@Name"/>
							</xsl:when>
							<xsl:when test="metadata/distinfo/resdesc!=''">
								<xsl:value-of select="metadata/distinfo/resdesc"/>
							</xsl:when>
						</xsl:choose>
					</objectName>
					<xsl:choose>
						<xsl:when test="/metadata/spdoinfo/direct ='Vector'">
							<dataFormat>
								<externallyDefinedFormat>
									<formatName>zip file with ARC/INFO shape file </formatName>
								</externallyDefinedFormat>
							</dataFormat>
						</xsl:when>
						<xsl:when test="/metadata/spdoinfo/direct ='Raster'">
							<dataFormat>
								<externallyDefinedFormat>
									<formatName>zip file with arcinfo .e00 exchange file
									</formatName>
								</externallyDefinedFormat>
							</dataFormat>
						</xsl:when>
					</xsl:choose>
					<!-- check for content -->
					<distribution>
						<online>
							<url>
								<xsl:value-of select="metadata/idinfo/citation/citeinfo/onlink"/>
							</url>
						</online>
					</distribution>
				</physical>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	<!--
		
		
		
		format the date -->
	<xsl:template name="FormatDate">
		<xsl:param name="DateTime"/>
		<!-- new date format 2006-01-14-->
		<xsl:variable name="year">
			<xsl:value-of select="substring($DateTime,1,4)"/>
		</xsl:variable>
		<xsl:variable name="month">
			<xsl:value-of select="substring($DateTime,5,2)"/>
		</xsl:variable>
		<xsl:variable name="day">
			<xsl:value-of select="substring($DateTime,7,2)"/>
		</xsl:variable>
		<xsl:value-of select="$year"/>
		<xsl:if test="(string-length($day) = 2)">
			<xsl:value-of select="'-'"/>
			<xsl:value-of select="$month"/>
			<xsl:value-of select="'-'"/>
			<xsl:value-of select="$day"/>
		</xsl:if>
	</xsl:template>
	<!--
		
		
		
		format a date and time -->
	<xsl:template name="FormatDateTime">
		<xsl:param name="DateTime"/>
		<!-- new date format 2006-01-14T08:55:22 -->
		<xsl:variable name="mo">
			<xsl:value-of select="substring($DateTime,1,3)"/>
		</xsl:variable>
		<xsl:variable name="day-temp">
			<xsl:value-of select="substring-after($DateTime,'-')"/>
		</xsl:variable>
		<xsl:variable name="day">
			<xsl:value-of select="substring-before($day-temp,'-')"/>
		</xsl:variable>
		<xsl:variable name="year-temp">
			<xsl:value-of select="substring-after($day-temp,'-')"/>
		</xsl:variable>
		<xsl:variable name="year">
			<xsl:value-of select="substring($year-temp,1,4)"/>
		</xsl:variable>
		<xsl:variable name="time">
			<xsl:value-of select="substring-after($year-temp,' ')"/>
		</xsl:variable>
		<xsl:variable name="hh">
			<xsl:value-of select="substring($time,1,2)"/>
		</xsl:variable>
		<xsl:variable name="mm">
			<xsl:value-of select="substring($time,4,2)"/>
		</xsl:variable>
		<xsl:variable name="ss">
			<xsl:value-of select="substring($time,7,2)"/>
		</xsl:variable>
		<xsl:value-of select="$year"/>
		<xsl:value-of select="'-'"/>
		<xsl:choose>
			<xsl:when test="$mo = 'Jan'">01</xsl:when>
			<xsl:when test="$mo = 'Feb'">02</xsl:when>
			<xsl:when test="$mo = 'Mar'">03</xsl:when>
			<xsl:when test="$mo = 'Apr'">04</xsl:when>
			<xsl:when test="$mo = 'May'">05</xsl:when>
			<xsl:when test="$mo = 'Jun'">06</xsl:when>
			<xsl:when test="$mo = 'Jul'">07</xsl:when>
			<xsl:when test="$mo = 'Aug'">08</xsl:when>
			<xsl:when test="$mo = 'Sep'">09</xsl:when>
			<xsl:when test="$mo = 'Oct'">10</xsl:when>
			<xsl:when test="$mo = 'Nov'">11</xsl:when>
			<xsl:when test="$mo = 'Dec'">12</xsl:when>
		</xsl:choose>
		<xsl:value-of select="'-'"/>
		<xsl:if test="(string-length($day) &lt; 2)">
			<xsl:value-of select="0"/>
		</xsl:if>
		<xsl:value-of select="$day"/>
		<xsl:value-of select="'T'"/>
		<xsl:value-of select="$hh"/>
		<xsl:value-of select="':'"/>
		<xsl:value-of select="$mm"/>
		<xsl:value-of select="':'"/>
		<xsl:value-of select="$ss"/>
	</xsl:template>
</xsl:stylesheet>
