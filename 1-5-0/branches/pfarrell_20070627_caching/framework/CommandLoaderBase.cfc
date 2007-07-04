<!---
License:
Copyright 2007 GreatBizTools, LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Copyright: GreatBizTools, LLC
Author: Peter J. Farrell (peter@mach-ii.com)
$Id$

Created version: 1.5.0
Updated version: 1.5.0
--->
<cfcomponent 
	displayname="CommandLoaderBase"
	output="false"
	hint="Base component to load commands for the framework.">
	
	<!---
	PROPERTIES
	--->
	
	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="void" output="false"
		hint="Initialization function called by the framework.">
		<!--- Overridden by child object. --->
	</cffunction>
	
	<cffunction name="configure" access="public" returntype="void"
		hint="Configures nothing.">
		<!--- DO NOTHING --->
	</cffunction>
	
	<!---
	PUBLIC FUNCTIONS
	--->
		
	<!---
	PROTECTED FUNCTIONS
	--->
	<cffunction name="createCommand" access="private" returntype="MachII.framework.Command" output="false">
		<cfargument name="commandNode" type="any" required="true" />
		<cfargument name="parentHandlerName" type="string" required="false" default="" />
		<cfargument name="parentHandlerType" type="string" required="false" default="" />
		
		<cfset var command = "" />

		<!--- Optimized: If/elseif blocks are faster than switch/case --->
		<!--- view-page --->
		<cfif arguments.commandNode.xmlName EQ "view-page">
			<cfset command = setupViewPage(arguments.commandNode) />
		<!--- notify --->
		<cfelseif arguments.commandNode.xmlName EQ "notify">
			<cfset command = setupNotify(arguments.commandNode) />
		<!--- announce --->
		<cfelseif arguments.commandNode.xmlName EQ "announce">
			<cfset command = setupAnnounce(arguments.commandNode) />
		<!--- event-mapping --->
		<cfelseif arguments.commandNode.xmlName EQ "event-mapping">
			<cfset command = setupEventMapping(arguments.commandNode) />
		<!--- execute --->
		<cfelseif arguments.commandNode.xmlName EQ "execute">
			<cfset command = setupExecute(arguments.commandNode) />
		<!--- filter --->
		<cfelseif arguments.commandNode.xmlName EQ "filter">
			<cfset command = setupFilter(arguments.commandNode) />
		<!--- event-bean --->
		<cfelseif arguments.commandNode.xmlName EQ "event-bean">
			<cfset command = setupEventBean(arguments.commandNode) />
		<!--- redirect --->
		<cfelseif arguments.commandNode.xmlName EQ "redirect">
			<cfset command = setupRedirect(arguments.commandNode) />
		<!--- event-arg --->
		<cfelseif arguments.commandNode.xmlName EQ "event-arg">
			<cfset command = setupEventArg(arguments.commandNode) />
		<!--- cache --->
		<cfelseif arguments.commandNode.xmlName EQ "cache">
			<cfset command = setupCache(arguments.commandNode, arguments.parentHandlerName, arguments.parentHandlerType) />
		<!--- default/unrecognized command --->
		<cfelse>
			<cfset command = setupDefault(arguments.commandNode) />
		</cfif>
		
		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupViewPage" access="private" returntype="MachII.framework.commands.ViewPageCommand" output="false"
		hint="Sets up a view-page command.">
		<cfargument name="commandNode" type="any" required="true" />
		
		<cfset var command = "" />
		<cfset var viewName = arguments.commandNode.xmlAttributes["name"] />
		<cfset var contentKey = "" />
		<cfset var contentArg = "" />
		<cfset var appendContent = "" />
		
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "contentKey")>
			<cfset contentKey = commandNode.xmlAttributes["contentKey"] />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "contentArg")>
			<cfset contentArg = commandNode.xmlAttributes["contentArg"] />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "append")>
			<cfset appendContent = arguments.commandNode.xmlAttributes["append"] />
		</cfif>
		<cfset command = CreateObject("component", "MachII.framework.commands.ViewPageCommand").init(viewName, contentKey, contentArg, appendContent) />
		
		<cfreturn command />
	</cffunction>

	<cffunction name="setupNotify" access="private" returntype="MachII.framework.commands.NotifyCommand" output="false"
		hint="Sets up a notify command.">
		<cfargument name="commandNode" type="any" required="true" />
		
		<cfset var command = "" />
		<cfset var notifyListener = arguments.commandNode.xmlAttributes["listener"] />
		<cfset var notifyMethod = arguments.commandNode.xmlAttributes["method"] />
		<cfset var notifyResultKey = "" />
		<cfset var notifyResultArg = "" />
		<cfset var listener = getAppManager().getListenerManager().getListener(notifyListener) />
		
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "resultKey")>
			<cfset notifyResultKey = arguments.commandNode.xmlAttributes["resultKey"] />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "resultArg")>
			<cfset notifyResultArg = arguments.commandNode.xmlAttributes["resultArg"] />
		</cfif>
		<cfset command = CreateObject("component", "MachII.framework.commands.NotifyCommand").init(listener, notifyMethod, notifyResultKey, notifyResultArg) />
		
		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupAnnounce" access="private" returntype="MachII.framework.commands.AnnounceCommand" output="false"
		hint="Sets up an announce command.">
		<cfargument name="commandNode" type="any" required="true" />
		
		<cfset var command = "" />
		<cfset var eventName = arguments.commandNode.xmlAttributes["event"] />
		<cfset var copyEventArgs = true />
		<cfset var moduleName = "" />
		
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "copyEventArgs")>
			<cfset copyEventArgs = arguments.commandNode.xmlAttributes["copyEventArgs"] />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "module")>
			<cfset moduleName = arguments.commandNode.xmlAttributes["module"] />
		<cfelse>
			<cfset moduleName = getAppManager().getModuleName() />
		</cfif>
		<cfset command = CreateObject("component", "MachII.framework.commands.AnnounceCommand").init(eventName, copyEventArgs, moduleName) />
		
		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupEventMapping" access="private" returntype="MachII.framework.commands.EventMappingCommand" output="false"
		hint="Sets up an event-mapping command.">
		<cfargument name="commandNode" type="any" required="true" />
		
		<cfset var command = "" />
		<cfset var eventName = arguments.commandNode.xmlAttributes["event"] />
		<cfset var mappingName = arguments.commandNode.xmlAttributes["mapping"] />
		<cfset var mappingModule = "" />
		
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "mappingModule")>
			<cfset mappingModule = arguments.commandNode.xmlAttributes["mappingModule"] />
		<cfelse>
			<cfset mappingModule = getAppManager().getModuleName() />
		</cfif>
		
		<cfset command = CreateObject("component", "MachII.framework.commands.EventMappingCommand").init(eventName, mappingName, mappingModule) />
		
		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupExecute" access="private" returntype="MachII.framework.commands.ExecuteCommand" output="false"
		hint="Sets up an execute command.">
		<cfargument name="commandNode" type="any" required="true" />
		
		<cfset var command = "" />
		<cfset var subroutine = arguments.commandNode.xmlAttributes["subroutine"] />
		
		<cfset command = CreateObject("component", "MachII.framework.commands.ExecuteCommand").init(subroutine) />
		
		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupFilter" access="private" returntype="MachII.framework.commands.FilterCommand" output="false"
		hint="Sets up a filter command.">
		<cfargument name="commandNode" type="any" required="true" />
		
		<cfset var command = "" />
		<cfset var filterName = arguments.commandNode.xmlAttributes["name"] />
		<cfset var filterParams = StructNew() />
		<cfset var paramNodes = arguments.commandNode.xmlChildren />
		<cfset var paramName = "" />
		<cfset var paramValue = "" />
		<cfset var filter = getAppManager().getFilterManager().getFilter(filterName) />
		<cfset var i = "" />

		<cfloop from="1" to="#ArrayLen(paramNodes)#" index="i">
			<cfset paramName = paramNodes[i].xmlAttributes["name"] />
			<cfif NOT StructKeyExists(paramNodes[i].xmlAttributes, "value")>
				<cfset paramValue = getAppManager().getUtils().recurseComplexValues(paramNodes[i]) />
			<cfelse>
				<cfset paramValue = paramNodes[i].xmlAttributes["value"] />
			</cfif>
			<cfset filterParams[paramName] = paramValue />
		</cfloop>

		<cfset command = CreateObject("component", "MachII.framework.commands.FilterCommand").init(filter, filterParams) />
		
		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupEventBean" access="private" returntype="MachII.framework.commands.EventBeanCommand" output="false"
		hint="Sets up a event-bean command.">
		<cfargument name="commandNode" type="any" required="true" />
		
		<cfset var command = "" />
		<cfset var beanName = arguments.commandNode.xmlAttributes["name"] />
		<cfset var beanType = arguments.commandNode.xmlAttributes["type"] />
		<cfset var beanFields = "" />
		<cfset var reinit = true />
		
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "fields")>
			<cfset beanFields = arguments.commandNode.xmlAttributes["fields"] />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "reinit")>
			<cfset reinit = arguments.commandNode.xmlAttributes["reinit"] />
		</cfif>
		<cfset command = CreateObject("component", "MachII.framework.commands.EventBeanCommand").init(beanName, beanType, beanFields, reinit) />

		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupRedirect" access="private" returntype="MachII.framework.commands.RedirectCommand" output="false"
		hint="Sets up a redirect command.">
		<cfargument name="commandNode" type="any" required="true" />
		
		<cfset var command = "" />
		<cfset var eventName = "" />
		<cfset var redirectUrl = getAppManager().getPropertyManager().getProperty("urlBase", "index.cfm") />
		<cfset var moduleName = "" />
		<cfset var args = "" />
		<cfset var persist = false />
		<cfset var persistArgs = "" />
		<cfset var statusType = "temporary" />
		<cfset var eventParameter = getAppManager().getPropertyManager().getProperty("eventParameter", "event") />
		<cfset var redirectPersistParameter = getAppManager().getPropertyManager().getProperty("redirectPersistParameter", "persistId") /> />
		
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "event")>
			<cfset eventName = arguments.commandNode.xmlAttributes["event"] />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "url")>
			<cfset redirectUrl = arguments.commandNode.xmlAttributes["url"] />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "args")>
			<cfset args = arguments.commandNode.xmlAttributes["args"] />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "persist")>
			<cfset persist = arguments.commandNode.xmlAttributes["persist"] />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "persistArgs")>
			<cfset persistArgs = arguments.commandNode.xmlAttributes["persistArgs"] />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "module")>
			<cfset moduleName = arguments.commandNode.xmlAttributes["module"] />
		<cfelse>
			<cfset moduleName = getAppManager().getModuleName() />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "statusType")>
			<cfset statusType = arguments.commandNode.xmlAttributes["statusType"] />
		</cfif>
		<cfset command = CreateObject("component", "MachII.framework.commands.RedirectCommand").init(eventName, eventParameter, redirectPersistParameter, moduleName, redirectUrl, args, persist, persistArgs, statusType) />
		
		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupEventArg" access="private" returntype="MachII.framework.commands.EventArgCommand" output="false"
		hint="Sets up an event-arg command.">
		<cfargument name="commandNode" type="any" required="true" />
		
		<cfset var command = "" />
		<cfset var argValue = "" />
		<cfset var argVariable = "" />
		<cfset var argName = arguments.commandNode.xmlAttributes["name"] />
		
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "value")>
			<cfset argValue = arguments.commandNode.xmlAttributes["value"] />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "variable")>
			<cfset argVariable = arguments.commandNode.xmlAttributes["variable"] />
		</cfif>
		<cfset command = CreateObject("component", "MachII.framework.commands.EventArgCommand").init(argName, argValue, argVariable) />
		
		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupCache" access="private" returntype="MachII.framework.commands.CacheCommand" output="false"
		hint="Sets up a cache command.">
		<cfargument name="commandNode" type="any" required="true" />
		<cfargument name="parentHandlerName" type="string" required="true" />
		<cfargument name="parentHandlerType" type="string" required="true" />
		
		<cfset var command = "" />
		<cfset var action = "cache" />
		<cfset var alias = "" />
		<cfset var handlerId = CreateUUID() />
		
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "action")>
			<cfset action = arguments.commandNode.xmlAttributes["action"] />
		</cfif>
		<cfif StructKeyExists(arguments.commandNode.xmlAttributes, "alias")>
			<cfset alias = arguments.commandNode.xmlAttributes["alias"] />
		</cfif>
		
		<!--- Build the correct data based on the action type --->
		<cfif action EQ "cache">
			<cfset handlerId = getAppManager().getCacheManager().loadCacheHandlerFromXml(arguments.commandNode, arguments.parentHandlerName, arguments.parentHandlerType) />
		<cfelseif action EQ "clear">
			<cfif NOT Len(alias)>
				<cfthrow type="MachII.framework.NoAlias"
					message="You must specify an alias attribute when using the cache action 'clear'."
					detail="#arguments.handlerType#-handler: '#arguments.handlerName#'" />
			</cfif>
		<cfelse>
			<cfthrow type="MachII.framework.NoAlias"
				message="You must specify an action attribute when using the cache command."
				detail="#arguments.handlerType#-handler: '#arguments.handlerName#'" />
		</cfif>
		
		<cfset command = CreateObject("component", "MachII.framework.commands.CacheCommand").init(action, handlerId, alias) />
		
		<cfreturn command />
	</cffunction>
	
	<cffunction name="setupDefault" access="private" returntype="MachII.framework.Command" output="false"
		hint="Sets up a default command.">
		
		<cfset var command = CreateObject("component", "MachII.framework.Command").init() />
		
		<cfreturn command />
	</cffunction>
	
</cfcomponent>