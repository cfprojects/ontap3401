<cfcomponent displayname="Zip File Format" extends="fileformat">
	<cfset variables.format = "zip">
	
	<cffunction name="getPathTo" access="private" output="false" returntype="string">
		<cfargument name="targetfile" type="string" required="true">
		<cfargument name="fromsource" type="string" required="true">
		<cfreturn getFS().getPathTo(targetfile,"",false,fromsource)>
	</cffunction>
	
	<cffunction name="read" access="public" output="false" returntype="any">
		<cfargument name="file" type="string" required="true">
		
		<cfscript>
			var zipFile = createObject("java","java.util.zip.ZipFile"); // ZipFile 
			var entries = ""; // Enumeration of ZipEntry 
			var entry = ""; // ZipEntry 
			var datestring = ""; 
			var timestring = ""; 
			var x = 0; 
			var qZip = QueryNew("comment,datelastmodified,name,directory,compressedsize,size,type,crc"); 
			
			if (DirectoryExists(file)) { return qZip; } 
			
			zipFile.init(arguments.file); 
			entries = zipFile.entries(); 
			
			while(entries.hasMoreElements()) { 
				entry = entries.nextElement(); 
				queryaddrow(qZip); x = qZip.recordcount; 
				
				if (entry.getTime() neq -1) { 
					qZip.datelastmodified[x] = getLib().epochToDate(entry.getTime()); 
					//cal.setTimeInMillis(entry.getTime()); // initializes the calendar with the time indicated by the epoch time in miliseconds from the entry object 
					//qZip.datelastmodified[x] = createDateTime(cal.get(cal.year),cal.get(cal.month),cal.get(cal.date),cal.get(cal.hour),cal.get(cal.minute),cal.get(cal.second)); 
				} 
				
				qZip.comment[x] = entry.getComment(); 
				qZip.name[x] = entry.getName(); 
				qZip.directory[x] = getDirectoryFromPath(qZip.name[x]); 
				qZip.compressedsize[x] = entry.getCompressedSize(); 
				qZip.size[x] = entry.getSize(); 
				qZip.crc[x] = entry.getCRC(); 
				qZip.type[x] = iif(entry.isDirectory(), de("Dir"), de("File")); 
			}
			zipFile.close(); 
		</cfscript>
		
		<cfreturn qZip>
	</cffunction>
	
	<cffunction name="write" access="public" output="false" returntype="void">
		<cfargument name="output" type="string" required="true">
		<cfargument name="file" type="string" required="true">
		<cfargument name="relativeFrom" type="string" required="true">
		<!--- 
			Original code for zip archive provided by Nathan Dintenfass nathan@changemedia.com 
			and contributed to cflib.org as zipFileNew version 1.1 19-Jan-2004 
			modified for use with the framework 
		--->
		<cfscript>
			//make a fileOutputStream object to put the ZipOutputStream into
			var fileOutput = createObject("java","java.io.FileOutputStream").init(arguments.file);
			//make a ZipOutputStream object to create the zip file
			var zipOutput = createObject("java","java.util.zip.ZipOutputStream").init(fileOutput);
			//make a byte array to use when creating the zip
			//yes, this is a bit of hack, but it works
			var byteArray = repeatString(" ",1024).getBytes();
			//we'll need to create an inputStream below for writing out to the zip file
			var input = CreateObject("java","java.io.FileInputStream");
			//we'll be making zipEntries below, so make a variable to hold them
			var zipEntry = CreateObject("java","java.util.zip.ZipEntry");
			var zipEntryPath = "";
			//we'll use this while reading each file
			var bytes = 0;
			//a var for looping below
			var ii = 1;
			//a an array of the files we'll put into the zip
			var fileArray = arrayNew(1);
			//an array of directories we need to traverse to find files below whatever is passed in
			var directoriesToTraverse = arrayNew(1);
			//a var to use when looping the directories to hold the contents of each one
			var directoryContents = "";
			//make a fileObject we can use to traverse directories with
			var fileObject = createObject("java","java.io.File").init(arguments.output);
			
			//
			// first, we'll deal with traversing the directory tree below the path passed in, so we get all files under the directory
			// in reality, this should be a separate function that goes out and traverses a directory, but cflib.org does not allow for UDF's that rely on other UDF's!!
			//
			
			//if this is a directory, let's set it in the directories we need to traverse
			if(fileObject.isDirectory()) { arrayAppend(directoriesToTraverse,fileObject); } 
			//if it's not a directory, add it the array of files to zip
			else { arrayAppend(fileArray,fileObject); } 
			
			//now, loop through directories iteratively until there are none left
			while(arrayLen(directoriesToTraverse)) { 
				//grab the contents of the first directory we need to traverse 
				directoryContents = directoriesToTraverse[1].listFiles();
				//loop through the contents of this directory
				for(ii = 1; ii LTE arrayLen(directoryContents); ii = ii + 1){			
					//if it's a directory, add it to those we need to traverse
					if(directoryContents[ii].isDirectory()) { arrayAppend(directoriesToTraverse,directoryContents[ii]);	} 
					//if it's not a directory, add it to the array of files we want to add
					else { arrayAppend(fileArray,directoryContents[ii]); } 
				} 
				//remove the directory we just added from the list of remaining directories 
				arrayDeleteAt(directoriesToTraverse,1); 
			} 
			
			//
			// And now, on to the zip file
			//
			
			//let's use the maximum compression 
			zipOutput.setLevel(9); 
			//loop over the array of files we are going to zip, adding each to the zipOutput
			for(ii = 1; ii LTE arrayLen(fileArray); ii = ii + 1){ 
				//make a fileInputStream object to read the file into 
				input.init(fileArray[ii]); 
				//make an entry for this file 
				zipEntry.init(getPathTo(fileArray[ii].getCanonicalPath(),relativeFrom)); 
				//put the entry into the zipOutput stream 
				zipOutput.putNextEntry(zipEntry); 
				// Transfer bytes from the file to the ZIP file 
				bytes = input.read(byteArray); 
				while (bytes GT 0) { 
					zipOutput.write(byteArray, 0, bytes); 
					bytes = input.read(byteArray); 
				} 
				//close out this entry 
				zipOutput.closeEntry(); 
				input.close(); 
			} 
			//close the zipOutput 
			zipOutput.close(); 
		</cfscript>
	</cffunction>
	
	<cffunction name="extract" access="public" output="false" returntype="void">
		<cfargument name="file" type="string" required="true">
		<cfargument name="destination" type="string" required="true">
		<cfargument name="selectedFile" type="string" required="false" default="">
		<!--- 
			Original code from Samuel Neff sam@serndesign.com 
			and contributed to cflib.org as unzipFile version 1 01-Sep-2003 
			modified for use with the framework 
		--->
		<cfscript>
			var zipFile = CreateObject("java","java.util.zip.ZipFile"); // ZipFile
			var entries = ""; // Enumeration of ZipEntry
			var entry = ""; // ZipEntry
			var fil = CreateObject("java","java.io.File"); //File
			var inStream = "";
			var filOutStream = ""; 
			var bufOutStream = "";
			var nm = ""; 
			var pth = ""; 
			var lenPth = ""; 
			var buffer = ""; 
			var l = 0; 
			var x = 0; 
			
			zipFile.init(arguments.file); 
			entries = zipFile.entries(); 
			
			while(entries.hasMoreElements()) { 
				entry = entries.nextElement(); 
				x = x + 1; nm = entry.getName(); 
				
				if (not len(trim(selectedFile)) or x is selectedFile or nm is selectedFile) { 
					nm = "/" & nm; 
					if(entry.isDirectory()) { 
						pth = getPath(nm,destination); 
						if (not directoryexists(pth)) { fil.init(pth); fil.mkdirs(); } 
					} else { 
						lenPth = len(nm) - len(getFileFromPath(nm)); 
						pth = iif(lenPth,"destination & left(nm, lenPth)","destination"); 
						
						if (NOT directoryExists(pth)) { fil.init(pth); fil.mkdirs(); } 
						
						filOutStream = createObject("java","java.io.FileOutputStream"); 
						filOutStream.init(destination & nm); 
						bufOutStream = createObject("java","java.io.BufferedOutputStream");
						bufOutStream.init(filOutStream); 
						
						inStream = zipFile.getInputStream(entry);
						buffer = repeatString(" ",1024).getBytes(); 
						
						l = inStream.read(buffer); 
						while(l GTE 0) { 
							bufOutStream.write(buffer, 0, l);
							l = inStream.read(buffer);
						} 
						
						inStream.close(); 
						bufOutStream.close(); 
						variables.fileMan.clearFileCache(getDirectoryFromPath(getPath(nm,destination)),false); 
					} 
				} 
			} 
			zipFile.close(); 
		</cfscript>
	</cffunction>
</cfcomponent>