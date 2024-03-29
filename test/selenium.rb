#!/bin/env ruby
# encoding: utf-8

# Copyright 2006 ThoughtWorks, Inc
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

# -----------------
# Original code by Aslak Hellesoy and Darren Hobbs
# This file has been automatically generated via XSL
# -----------------

require 'net/http'
require 'uri'
require 'cgi'

# Defines an object that runs Selenium commands.
# 
# ===Element Locators
# Element Locators tell Selenium which HTML element a command refers to.
# The format of a locator is:
# <em>locatorType</em><b>=</b><em>argument</em>
# We support the following strategies for locating elements:
# 
# *    <b>identifier</b>=<em>id</em>: 
# Select the element with the specified @id attribute. If no match is
# found, select the first element whose @name attribute is <em>id</em>.
# (This is normally the default; see below.)
# *    <b>id</b>=<em>id</em>:
# Select the element with the specified @id attribute.
# *    <b>name</b>=<em>name</em>:
# Select the first element with the specified @name attribute.
# *    username
# *    name=username
# 
# The name may optionally be followed by one or more <em>element-filters</em>, separated from the name by whitespace.  If the <em>filterType</em> is not specified, <b>value</b> is assumed.
# *    name=flavour value=chocolate
# 
# 
# *    <b>dom</b>=<em>javascriptExpression</em>: 
# 
# Find an element by evaluating the specified string.  This allows you to traverse the HTML Document Object
# Model using JavaScript.  Note that you must not return a value in this string; simply make it the last expression in the block.
# *    dom=document.forms['myForm'].myDropdown
# *    dom=document.images[56]
# *    dom=function foo() { return document.links[1]; }; foo();
# 
# 
# *    <b>xpath</b>=<em>xpathExpression</em>: 
# Locate an element using an XPath expression.
# *    xpath=//img[@alt='The image alt text']
# *    xpath=//table[@id='table1']//tr[4]/td[2]
# *    xpath=//a[contains(@href,'#id1')]
# *    xpath=//a[contains(@href,'#id1')]/@class
# *    xpath=(//table[@class='stylee'])//th[text()='theHeaderText']/../td
# *    xpath=//input[@name='name2' and @value='yes']
# *    xpath=//*[text()="right"]
# 
# 
# *    <b>link</b>=<em>textPattern</em>:
# Select the link (anchor) element which contains text matching the
# specified <em>pattern</em>.
# *    link=The link text
# 
# 
# *    <b>css</b>=<em>cssSelectorSyntax</em>:
# Select the element using css selectors. Please refer to CSS2 selectors, CSS3 selectors for more information. You can also check the TestCssLocators test in the selenium test suite for an example of usage, which is included in the downloaded selenium core package.
# *    css=a[href="#id3"]
# *    css=span#firstChild + span
# 
# Currently the css selector locator supports all css1, css2 and css3 selectors except namespace in css3, some pseudo classes(:nth-of-type, :nth-last-of-type, :first-of-type, :last-of-type, :only-of-type, :visited, :hover, :active, :focus, :indeterminate) and pseudo elements(::first-line, ::first-letter, ::selection, ::before, ::after). 
# 
# 
# 
# Without an explicit locator prefix, Selenium uses the following default
# strategies:
# 
# *    <b>dom</b>, for locators starting with "document."
# *    <b>xpath</b>, for locators starting with "//"
# *    <b>identifier</b>, otherwise
# 
# ===Element FiltersElement filters can be used with a locator to refine a list of candidate elements.  They are currently used only in the 'name' element-locator.
# Filters look much like locators, ie.
# <em>filterType</em><b>=</b><em>argument</em>Supported element-filters are:
# <b>value=</b><em>valuePattern</em>
# 
# Matches elements based on their values.  This is particularly useful for refining a list of similarly-named toggle-buttons.<b>index=</b><em>index</em>
# 
# Selects a single element based on its position in the list (offset from zero).===String-match Patterns
# Various Pattern syntaxes are available for matching string values:
# 
# *    <b>glob:</b><em>pattern</em>:
# Match a string against a "glob" (aka "wildmat") pattern. "Glob" is a
# kind of limited regular-expression syntax typically used in command-line
# shells. In a glob pattern, "*" represents any sequence of characters, and "?"
# represents any single character. Glob patterns match against the entire
# string.
# *    <b>regexp:</b><em>regexp</em>:
# Match a string using a regular-expression. The full power of JavaScript
# regular-expressions is available.
# *    <b>regexpi:</b><em>regexpi</em>:
# Match a string using a case-insensitive regular-expression.
# *    <b>exact:</b><em>string</em>:
# 
# Match a string exactly, verbatim, without any of that fancy wildcard
# stuff.
# 
# 
# If no pattern prefix is specified, Selenium assumes that it's a "glob"
# pattern.
# 
# 
# For commands that return multiple values (such as verifySelectOptions),
# the string being matched is a comma-separated list of the return values,
# where both commas and backslashes in the values are backslash-escaped.
# When providing a pattern, the optional matching syntax (i.e. glob,
# regexp, etc.) is specified once, as usual, at the beginning of the
# pattern.
# 
# 
module Selenium

    class SeleniumDriver
        include Selenium
    
        def initialize(server_host, server_port, browserStartCommand, browserURL, timeout=30000)
            @server_host = server_host
            @server_port = server_port
            @browserStartCommand = browserStartCommand
            @browserURL = browserURL
            @timeout = timeout
        end
        
        def to_s
            "SeleniumDriver"
        end

        def start()
            result = get_string("getNewBrowserSession", [@browserStartCommand, @browserURL])
            @session_id = result
        end
        
        def stop()
            do_command("testComplete", [])
            @session_id = nil
        end

        def do_command(verb, args)
            Timeout.timeout(@timeout) do
                http = Net::HTTP.new(@server_host, @server_port)
                command_string = '/selenium-server/driver/?cmd=' + CGI::escape(verb)
                args.length.times do |i|
                    arg_num = (i+1).to_s
                    command_string = command_string + "&" + arg_num + "=" + CGI::escape(args[i].to_s)
                end
                if @session_id != nil
                    command_string = command_string + "&sessionId=" + @session_id.to_s
                end
                #print "Requesting --->" + command_string + "\n"
                response = http.get(command_string)
                #print "RESULT: " + response.body + "\n\n"
                if (response.body[0..1] != "OK")
                  binding.irb
                  raise SeleniumCommandError, response.body
                end
                return response.body
            end
        end
        
        def get_string(verb, args)
            result = do_command(verb, args)
            return result[3..result.length]
        end
        
        def get_string_array(verb, args)
            csv = get_string(verb, args)
            token = ""
            tokens = []
            escape = false
            csv.split(//).each do |letter|
                if escape
                    token = token + letter
                    escape = false
                    next
                end
                if (letter == '\\')
                    escape = true
                elsif (letter == ',')
                    tokens.push(token)
                    token = ""
                else
                    token = token + letter
                end
            end
            tokens.push(token)
            return tokens
        end
    
        def get_number(verb, args)
            # Is there something I need to do here?
            return get_string(verb, args)
        end
        
        def get_number_array(verb, args)
            # Is there something I need to do here?
            return get_string_array(verb, args)
        end
    
        def get_boolean(verb, args)
            boolstr = get_string(verb, args)
            if ("true" == boolstr)
                return true
            end
            if ("false" == boolstr)
                return false
            end
            raise ValueError, "result is neither 'true' nor 'false': " + boolstr
        end
        
        def get_boolean_array(verb, args)
            boolarr = get_string_array(verb, args)
            boolarr.length.times do |i|
                if ("true" == boolstr)
                    boolarr[i] = true
                    next
                end
                if ("false" == boolstr)
                    boolarr[i] = false
                    next
                end
                raise ValueError, "result is neither 'true' nor 'false': " + boolarr[i]
            end
            return boolarr
        end



        # Clicks on a link, button, checkbox or radio button. If the click action
        # causes a new page to load (like a link usually does), call
        # waitForPageToLoad.
        #
        # 'locator' is an element locator
        def click(locator)
            do_command("click", [locator,])
        end


        # Double clicks on a link, button, checkbox or radio button. If the double click action
        # causes a new page to load (like a link usually does), call
        # waitForPageToLoad.
        #
        # 'locator' is an element locator
        def double_click(locator)
            do_command("doubleClick", [locator,])
        end


        # Simulates opening the context menu for the specified element (as might happen if the user "right-clicked" on the element).
        #
        # 'locator' is an element locator
        def context_menu(locator)
            do_command("contextMenu", [locator,])
        end


        # Clicks on a link, button, checkbox or radio button. If the click action
        # causes a new page to load (like a link usually does), call
        # waitForPageToLoad.
        #
        # 'locator' is an element locator
        # 'coordString' is specifies the x,y position (i.e. - 10,20) of the mouse      event relative to the element returned by the locator.
        def click_at(locator,coordString)
            do_command("clickAt", [locator,coordString,])
        end


        # Doubleclicks on a link, button, checkbox or radio button. If the action
        # causes a new page to load (like a link usually does), call
        # waitForPageToLoad.
        #
        # 'locator' is an element locator
        # 'coordString' is specifies the x,y position (i.e. - 10,20) of the mouse      event relative to the element returned by the locator.
        def double_click_at(locator,coordString)
            do_command("doubleClickAt", [locator,coordString,])
        end


        # Simulates opening the context menu for the specified element (as might happen if the user "right-clicked" on the element).
        #
        # 'locator' is an element locator
        # 'coordString' is specifies the x,y position (i.e. - 10,20) of the mouse      event relative to the element returned by the locator.
        def context_menu_at(locator,coordString)
            do_command("contextMenuAt", [locator,coordString,])
        end


        # Explicitly simulate an event, to trigger the corresponding "on<em>event</em>"
        # handler.
        #
        # 'locator' is an element locator
        # 'eventName' is the event name, e.g. "focus" or "blur"
        def fire_event(locator,eventName)
            do_command("fireEvent", [locator,eventName,])
        end


        # Move the focus to the specified element; for example, if the element is an input field, move the cursor to that field.
        #
        # 'locator' is an element locator
        def focus(locator)
            do_command("focus", [locator,])
        end


        # Simulates a user pressing and releasing a key.
        #
        # 'locator' is an element locator
        # 'keySequence' is Either be a string("\" followed by the numeric keycode  of the key to be pressed, normally the ASCII value of that key), or a single  character. For example: "w", "\119".
        def key_press(locator,keySequence)
            do_command("keyPress", [locator,keySequence,])
        end


        # Press the shift key and hold it down until doShiftUp() is called or a new page is loaded.
        #
        def shift_key_down()
            do_command("shiftKeyDown", [])
        end


        # Release the shift key.
        #
        def shift_key_up()
            do_command("shiftKeyUp", [])
        end


        # Press the meta key and hold it down until doMetaUp() is called or a new page is loaded.
        #
        def meta_key_down()
            do_command("metaKeyDown", [])
        end


        # Release the meta key.
        #
        def meta_key_up()
            do_command("metaKeyUp", [])
        end


        # Press the alt key and hold it down until doAltUp() is called or a new page is loaded.
        #
        def alt_key_down()
            do_command("altKeyDown", [])
        end


        # Release the alt key.
        #
        def alt_key_up()
            do_command("altKeyUp", [])
        end


        # Press the control key and hold it down until doControlUp() is called or a new page is loaded.
        #
        def control_key_down()
            do_command("controlKeyDown", [])
        end


        # Release the control key.
        #
        def control_key_up()
            do_command("controlKeyUp", [])
        end


        # Simulates a user pressing a key (without releasing it yet).
        #
        # 'locator' is an element locator
        # 'keySequence' is Either be a string("\" followed by the numeric keycode  of the key to be pressed, normally the ASCII value of that key), or a single  character. For example: "w", "\119".
        def key_down(locator,keySequence)
            do_command("keyDown", [locator,keySequence,])
        end


        # Simulates a user releasing a key.
        #
        # 'locator' is an element locator
        # 'keySequence' is Either be a string("\" followed by the numeric keycode  of the key to be pressed, normally the ASCII value of that key), or a single  character. For example: "w", "\119".
        def key_up(locator,keySequence)
            do_command("keyUp", [locator,keySequence,])
        end


        # Simulates a user hovering a mouse over the specified element.
        #
        # 'locator' is an element locator
        def mouse_over(locator)
            do_command("mouseOver", [locator,])
        end


        # Simulates a user moving the mouse pointer away from the specified element.
        #
        # 'locator' is an element locator
        def mouse_out(locator)
            do_command("mouseOut", [locator,])
        end


        # Simulates a user pressing the mouse button (without releasing it yet) on
        # the specified element.
        #
        # 'locator' is an element locator
        def mouse_down(locator)
            do_command("mouseDown", [locator,])
        end


        # Simulates a user pressing the mouse button (without releasing it yet) at
        # the specified location.
        #
        # 'locator' is an element locator
        # 'coordString' is specifies the x,y position (i.e. - 10,20) of the mouse      event relative to the element returned by the locator.
        def mouse_down_at(locator,coordString)
            do_command("mouseDownAt", [locator,coordString,])
        end


        # Simulates the event that occurs when the user releases the mouse button (i.e., stops
        # holding the button down) on the specified element.
        #
        # 'locator' is an element locator
        def mouse_up(locator)
            do_command("mouseUp", [locator,])
        end


        # Simulates the event that occurs when the user releases the mouse button (i.e., stops
        # holding the button down) at the specified location.
        #
        # 'locator' is an element locator
        # 'coordString' is specifies the x,y position (i.e. - 10,20) of the mouse      event relative to the element returned by the locator.
        def mouse_up_at(locator,coordString)
            do_command("mouseUpAt", [locator,coordString,])
        end


        # Simulates a user pressing the mouse button (without releasing it yet) on
        # the specified element.
        #
        # 'locator' is an element locator
        def mouse_move(locator)
            do_command("mouseMove", [locator,])
        end


        # Simulates a user pressing the mouse button (without releasing it yet) on
        # the specified element.
        #
        # 'locator' is an element locator
        # 'coordString' is specifies the x,y position (i.e. - 10,20) of the mouse      event relative to the element returned by the locator.
        def mouse_move_at(locator,coordString)
            do_command("mouseMoveAt", [locator,coordString,])
        end


        # Sets the value of an input field, as though you typed it in.
        # 
        # Can also be used to set the value of combo boxes, check boxes, etc. In these cases,
        # value should be the value of the option selected, not the visible text.
        # 
        #
        # 'locator' is an element locator
        # 'value' is the value to type
        def type(locator,value)
            do_command("type", [locator,value,])
        end


        # Simulates keystroke events on the specified element, as though you typed the value key-by-key.
        # 
        # This is a convenience method for calling keyDown, keyUp, keyPress for every character in the specified string;
        # this is useful for dynamic UI widgets (like auto-completing combo boxes) that require explicit key events.
        # Unlike the simple "type" command, which forces the specified value into the page directly, this command
        # may or may not have any visible effect, even in cases where typing keys would normally have a visible effect.
        # For example, if you use "typeKeys" on a form element, you may or may not see the results of what you typed in
        # the field.
        # In some cases, you may need to use the simple "type" command to set the value of the field and then the "typeKeys" command to
        # send the keystroke events corresponding to what you just typed.
        # 
        #
        # 'locator' is an element locator
        # 'value' is the value to type
        def type_keys(locator,value)
            do_command("typeKeys", [locator,value,])
        end


        # Set execution speed (i.e., set the millisecond length of a delay which will follow each selenium operation).  By default, there is no such delay, i.e.,
        # the delay is 0 milliseconds.
        #
        # 'value' is the number of milliseconds to pause after operation
        def set_speed(value)
            do_command("setSpeed", [value,])
        end


        # Get execution speed (i.e., get the millisecond length of the delay following each selenium operation).  By default, there is no such delay, i.e.,
        # the delay is 0 milliseconds.
        # 
        # See also setSpeed.
        #
        def get_speed()
            return get_string("getSpeed", [])
        end


        # Check a toggle-button (checkbox/radio)
        #
        # 'locator' is an element locator
        def check(locator)
            do_command("check", [locator,])
        end


        # Uncheck a toggle-button (checkbox/radio)
        #
        # 'locator' is an element locator
        def uncheck(locator)
            do_command("uncheck", [locator,])
        end


        # Select an option from a drop-down using an option locator.
        # 
        # 
        # Option locators provide different ways of specifying options of an HTML
        # Select element (e.g. for selecting a specific option, or for asserting
        # that the selected option satisfies a specification). There are several
        # forms of Select Option Locator.
        # 
        # *    <b>label</b>=<em>labelPattern</em>:
        # matches options based on their labels, i.e. the visible text. (This
        # is the default.)
        # *    label=regexp:^[Oo]ther
        # 
        # 
        # *    <b>value</b>=<em>valuePattern</em>:
        # matches options based on their values.
        # *    value=other
        # 
        # 
        # *    <b>id</b>=<em>id</em>:
        # 
        # matches options based on their ids.
        # *    id=option1
        # 
        # 
        # *    <b>index</b>=<em>index</em>:
        # matches an option based on its index (offset from zero).
        # *    index=2
        # 
        # 
        # 
        # 
        # If no option locator prefix is provided, the default behaviour is to match on <b>label</b>.
        # 
        # 
        #
        # 'selectLocator' is an element locator identifying a drop-down menu
        # 'optionLocator' is an option locator (a label by default)
        def select(selectLocator,optionLocator)
            do_command("select", [selectLocator,optionLocator,])
        end


        # Add a selection to the set of selected options in a multi-select element using an option locator.
        # 
        # @see #doSelect for details of option locators
        #
        # 'locator' is an element locator identifying a multi-select box
        # 'optionLocator' is an option locator (a label by default)
        def add_selection(locator,optionLocator)
            do_command("addSelection", [locator,optionLocator,])
        end


        # Remove a selection from the set of selected options in a multi-select element using an option locator.
        # 
        # @see #doSelect for details of option locators
        #
        # 'locator' is an element locator identifying a multi-select box
        # 'optionLocator' is an option locator (a label by default)
        def remove_selection(locator,optionLocator)
            do_command("removeSelection", [locator,optionLocator,])
        end


        # Unselects all of the selected options in a multi-select element.
        #
        # 'locator' is an element locator identifying a multi-select box
        def remove_all_selections(locator)
            do_command("removeAllSelections", [locator,])
        end


        # Submit the specified form. This is particularly useful for forms without
        # submit buttons, e.g. single-input "Search" forms.
        #
        # 'formLocator' is an element locator for the form you want to submit
        def submit(formLocator)
            do_command("submit", [formLocator,])
        end


        # Opens an URL in the test frame. This accepts both relative and absolute
        # URLs.
        # 
        # The "open" command waits for the page to load before proceeding,
        # ie. the "AndWait" suffix is implicit.
        # 
        # <em>Note</em>: The URL must be on the same domain as the runner HTML
        # due to security restrictions in the browser (Same Origin Policy). If you
        # need to open an URL on another domain, use the Selenium Server to start a
        # new browser session on that domain.
        #
        # 'url' is the URL to open; may be relative or absolute
        def open(url)
            do_command("open", [url,])
        end


        # Opens a popup window (if a window with that ID isn't already open).
        # After opening the window, you'll need to select it using the selectWindow
        # command.
        # 
        # This command can also be a useful workaround for bug SEL-339.  In some cases, Selenium will be unable to intercept a call to window.open (if the call occurs during or before the "onLoad" event, for example).
        # In those cases, you can force Selenium to notice the open window's name by using the Selenium openWindow command, using
        # an empty (blank) url, like this: openWindow("", "myFunnyWindow").
        # 
        #
        # 'url' is the URL to open, which can be blank
        # 'windowID' is the JavaScript window ID of the window to select
        def open_window(url,windowID)
            do_command("openWindow", [url,windowID,])
        end


        # Selects a popup window using a window locator; once a popup window has been selected, all
        # commands go to that window. To select the main window again, use null
        # as the target.
        # 
        # 
        # 
        # Window locators provide different ways of specifying the window object:
        # by title, by internal JavaScript "name," or by JavaScript variable.
        # 
        # *    <b>title</b>=<em>My Special Window</em>:
        # Finds the window using the text that appears in the title bar.  Be careful;
        # two windows can share the same title.  If that happens, this locator will
        # just pick one.
        # 
        # *    <b>name</b>=<em>myWindow</em>:
        # Finds the window using its internal JavaScript "name" property.  This is the second 
        # parameter "windowName" passed to the JavaScript method window.open(url, windowName, windowFeatures, replaceFlag)
        # (which Selenium intercepts).
        # 
        # *    <b>var</b>=<em>variableName</em>:
        # Some pop-up windows are unnamed (anonymous), but are associated with a JavaScript variable name in the current
        # application window, e.g. "window.foo = window.open(url);".  In those cases, you can open the window using
        # "var=foo".
        # 
        # 
        # 
        # If no window locator prefix is provided, we'll try to guess what you mean like this:
        # 1.) if windowID is null, (or the string "null") then it is assumed the user is referring to the original window instantiated by the browser).
        # 2.) if the value of the "windowID" parameter is a JavaScript variable name in the current application window, then it is assumed
        # that this variable contains the return value from a call to the JavaScript window.open() method.
        # 3.) Otherwise, selenium looks in a hash it maintains that maps string names to window "names".
        # 4.) If <em>that</em> fails, we'll try looping over all of the known windows to try to find the appropriate "title".
        # Since "title" is not necessarily unique, this may have unexpected behavior.
        # If you're having trouble figuring out the name of a window that you want to manipulate, look at the Selenium log messages
        # which identify the names of windows created via window.open (and therefore intercepted by Selenium).  You will see messages
        # like the following for each window as it is opened:
        # <tt>debug: window.open call intercepted; window ID (which you can use with selectWindow()) is "myNewWindow"</tt>
        # In some cases, Selenium will be unable to intercept a call to window.open (if the call occurs during or before the "onLoad" event, for example).
        # (This is bug SEL-339.)  In those cases, you can force Selenium to notice the open window's name by using the Selenium openWindow command, using
        # an empty (blank) url, like this: openWindow("", "myFunnyWindow").
        # 
        #
        # 'windowID' is the JavaScript window ID of the window to select
        def select_window(windowID)
            do_command("selectWindow", [windowID,])
        end


        # Selects a frame within the current window.  (You may invoke this command
        # multiple times to select nested frames.)  To select the parent frame, use
        # "relative=parent" as a locator; to select the top frame, use "relative=top".
        # You can also select a frame by its 0-based index number; select the first frame with
        # "index=0", or the third frame with "index=2".
        # 
        # You may also use a DOM expression to identify the frame you want directly,
        # like this: <tt>dom=frames["main"].frames["subframe"]</tt>
        # 
        #
        # 'locator' is an element locator identifying a frame or iframe
        def select_frame(locator)
            do_command("selectFrame", [locator,])
        end


        # Determine whether current/locator identify the frame containing this running code.
        # 
        # This is useful in proxy injection mode, where this code runs in every
        # browser frame and window, and sometimes the selenium server needs to identify
        # the "current" frame.  In this case, when the test calls selectFrame, this
        # routine is called for each frame to figure out which one has been selected.
        # The selected frame will return true, while all others will return false.
        # 
        #
        # 'currentFrameString' is starting frame
        # 'target' is new frame (which might be relative to the current one)
        def get_whether_this_frame_match_frame_expression(currentFrameString,target)
            return get_boolean("getWhetherThisFrameMatchFrameExpression", [currentFrameString,target,])
        end


        # Determine whether currentWindowString plus target identify the window containing this running code.
        # 
        # This is useful in proxy injection mode, where this code runs in every
        # browser frame and window, and sometimes the selenium server needs to identify
        # the "current" window.  In this case, when the test calls selectWindow, this
        # routine is called for each window to figure out which one has been selected.
        # The selected window will return true, while all others will return false.
        # 
        #
        # 'currentWindowString' is starting window
        # 'target' is new window (which might be relative to the current one, e.g., "_parent")
        def get_whether_this_window_match_window_expression(currentWindowString,target)
            return get_boolean("getWhetherThisWindowMatchWindowExpression", [currentWindowString,target,])
        end


        # Waits for a popup window to appear and load up.
        #
        # 'windowID' is the JavaScript window "name" of the window that will appear (not the text of the title bar)
        # 'timeout' is a timeout in milliseconds, after which the action will return with an error
        def wait_for_pop_up(windowID,timeout)
            do_command("waitForPopUp", [windowID,timeout,])
        end


        # By default, Selenium's overridden window.confirm() function will
        # return true, as if the user had manually clicked OK; after running
        # this command, the next call to confirm() will return false, as if
        # the user had clicked Cancel.  Selenium will then resume using the
        # default behavior for future confirmations, automatically returning 
        # true (OK) unless/until you explicitly call this command for each
        # confirmation.
        #
        def choose_cancel_on_next_confirmation()
            do_command("chooseCancelOnNextConfirmation", [])
        end


        # Undo the effect of calling chooseCancelOnNextConfirmation.  Note
        # that Selenium's overridden window.confirm() function will normally automatically
        # return true, as if the user had manually clicked OK, so you shouldn't
        # need to use this command unless for some reason you need to change
        # your mind prior to the next confirmation.  After any confirmation, Selenium will resume using the
        # default behavior for future confirmations, automatically returning 
        # true (OK) unless/until you explicitly call chooseCancelOnNextConfirmation for each
        # confirmation.
        #
        def choose_ok_on_next_confirmation()
            do_command("chooseOkOnNextConfirmation", [])
        end


        # Instructs Selenium to return the specified answer string in response to
        # the next JavaScript prompt [window.prompt()].
        #
        # 'answer' is the answer to give in response to the prompt pop-up
        def answer_on_next_prompt(answer)
            do_command("answerOnNextPrompt", [answer,])
        end


        # Simulates the user clicking the "back" button on their browser.
        #
        def go_back()
            do_command("goBack", [])
        end


        # Simulates the user clicking the "Refresh" button on their browser.
        #
        def refresh()
            do_command("refresh", [])
        end


        # Simulates the user clicking the "close" button in the titlebar of a popup
        # window or tab.
        #
        def close()
            do_command("close", [])
        end


        # Has an alert occurred?
        # 
        # 
        # This function never throws an exception
        # 
        # 
        #
        def is_alert_present()
            return get_boolean("isAlertPresent", [])
        end


        # Has a prompt occurred?
        # 
        # 
        # This function never throws an exception
        # 
        # 
        #
        def is_prompt_present()
            return get_boolean("isPromptPresent", [])
        end


        # Has confirm() been called?
        # 
        # 
        # This function never throws an exception
        # 
        # 
        #
        def is_confirmation_present()
            return get_boolean("isConfirmationPresent", [])
        end


        # Retrieves the message of a JavaScript alert generated during the previous action, or fail if there were no alerts.
        # 
        # Getting an alert has the same effect as manually clicking OK. If an
        # alert is generated but you do not get/verify it, the next Selenium action
        # will fail.
        # NOTE: under Selenium, JavaScript alerts will NOT pop up a visible alert
        # dialog.
        # NOTE: Selenium does NOT support JavaScript alerts that are generated in a
        # page's onload() event handler. In this case a visible dialog WILL be
        # generated and Selenium will hang until someone manually clicks OK.
        # 
        #
        def get_alert()
            return get_string("getAlert", [])
        end


        # Retrieves the message of a JavaScript confirmation dialog generated during
        # the previous action.
        # 
        # 
        # By default, the confirm function will return true, having the same effect
        # as manually clicking OK. This can be changed by prior execution of the
        # chooseCancelOnNextConfirmation command. If an confirmation is generated
        # but you do not get/verify it, the next Selenium action will fail.
        # 
        # 
        # NOTE: under Selenium, JavaScript confirmations will NOT pop up a visible
        # dialog.
        # 
        # 
        # NOTE: Selenium does NOT support JavaScript confirmations that are
        # generated in a page's onload() event handler. In this case a visible
        # dialog WILL be generated and Selenium will hang until you manually click
        # OK.
        # 
        # 
        #
        def get_confirmation()
            return get_string("getConfirmation", [])
        end


        # Retrieves the message of a JavaScript question prompt dialog generated during
        # the previous action.
        # 
        # Successful handling of the prompt requires prior execution of the
        # answerOnNextPrompt command. If a prompt is generated but you
        # do not get/verify it, the next Selenium action will fail.
        # NOTE: under Selenium, JavaScript prompts will NOT pop up a visible
        # dialog.
        # NOTE: Selenium does NOT support JavaScript prompts that are generated in a
        # page's onload() event handler. In this case a visible dialog WILL be
        # generated and Selenium will hang until someone manually clicks OK.
        # 
        #
        def get_prompt()
            return get_string("getPrompt", [])
        end


        # Gets the absolute URL of the current page.
        #
        def get_location()
            return get_string("getLocation", [])
        end


        # Gets the title of the current page.
        #
        def get_title()
            return get_string("getTitle", [])
        end


        # Gets the entire text of the page.
        #
        def get_body_text()
            return get_string("getBodyText", [])
        end


        # Gets the (whitespace-trimmed) value of an input field (or anything else with a value parameter).
        # For checkbox/radio elements, the value will be "on" or "off" depending on
        # whether the element is checked or not.
        #
        # 'locator' is an element locator
        def get_value(locator)
            return get_string("getValue", [locator,])
        end


        # Gets the text of an element. This works for any element that contains
        # text. This command uses either the textContent (Mozilla-like browsers) or
        # the innerText (IE-like browsers) of the element, which is the rendered
        # text shown to the user.
        #
        # 'locator' is an element locator
        def get_text(locator)
            return get_string("getText", [locator,])
        end


        # Briefly changes the backgroundColor of the specified element yellow.  Useful for debugging.
        #
        # 'locator' is an element locator
        def highlight(locator)
            do_command("highlight", [locator,])
        end


        # Gets the result of evaluating the specified JavaScript snippet.  The snippet may
        # have multiple lines, but only the result of the last line will be returned.
        # 
        # Note that, by default, the snippet will run in the context of the "selenium"
        # object itself, so <tt>this</tt> will refer to the Selenium object.  Use <tt>window</tt> to
        # refer to the window of your application, e.g. <tt>window.document.getElementById('foo')</tt>
        # If you need to use
        # a locator to refer to a single element in your application page, you can
        # use <tt>this.browserbot.findElement("id=foo")</tt> where "id=foo" is your locator.
        # 
        #
        # 'script' is the JavaScript snippet to run
        def get_eval(script)
            return get_string("getEval", [script,])
        end


        # Gets whether a toggle-button (checkbox/radio) is checked.  Fails if the specified element doesn't exist or isn't a toggle-button.
        #
        # 'locator' is an element locator pointing to a checkbox or radio button
        def is_checked(locator)
            return get_boolean("isChecked", [locator,])
        end


        # Gets the text from a cell of a table. The cellAddress syntax
        # tableLocator.row.column, where row and column start at 0.
        #
        # 'tableCellAddress' is a cell address, e.g. "foo.1.4"
        def get_table(tableCellAddress)
            return get_string("getTable", [tableCellAddress,])
        end


        # Gets all option labels (visible text) for selected options in the specified select or multi-select element.
        #
        # 'selectLocator' is an element locator identifying a drop-down menu
        def get_selected_labels(selectLocator)
            return get_string_array("getSelectedLabels", [selectLocator,])
        end


        # Gets option label (visible text) for selected option in the specified select element.
        #
        # 'selectLocator' is an element locator identifying a drop-down menu
        def get_selected_label(selectLocator)
            return get_string("getSelectedLabel", [selectLocator,])
        end


        # Gets all option values (value attributes) for selected options in the specified select or multi-select element.
        #
        # 'selectLocator' is an element locator identifying a drop-down menu
        def get_selected_values(selectLocator)
            return get_string_array("getSelectedValues", [selectLocator,])
        end


        # Gets option value (value attribute) for selected option in the specified select element.
        #
        # 'selectLocator' is an element locator identifying a drop-down menu
        def get_selected_value(selectLocator)
            return get_string("getSelectedValue", [selectLocator,])
        end


        # Gets all option indexes (option number, starting at 0) for selected options in the specified select or multi-select element.
        #
        # 'selectLocator' is an element locator identifying a drop-down menu
        def get_selected_indexes(selectLocator)
            return get_string_array("getSelectedIndexes", [selectLocator,])
        end


        # Gets option index (option number, starting at 0) for selected option in the specified select element.
        #
        # 'selectLocator' is an element locator identifying a drop-down menu
        def get_selected_index(selectLocator)
            return get_string("getSelectedIndex", [selectLocator,])
        end


        # Gets all option element IDs for selected options in the specified select or multi-select element.
        #
        # 'selectLocator' is an element locator identifying a drop-down menu
        def get_selected_ids(selectLocator)
            return get_string_array("getSelectedIds", [selectLocator,])
        end


        # Gets option element ID for selected option in the specified select element.
        #
        # 'selectLocator' is an element locator identifying a drop-down menu
        def get_selected_id(selectLocator)
            return get_string("getSelectedId", [selectLocator,])
        end


        # Determines whether some option in a drop-down menu is selected.
        #
        # 'selectLocator' is an element locator identifying a drop-down menu
        def is_something_selected(selectLocator)
            return get_boolean("isSomethingSelected", [selectLocator,])
        end


        # Gets all option labels in the specified select drop-down.
        #
        # 'selectLocator' is an element locator identifying a drop-down menu
        def get_select_options(selectLocator)
            return get_string_array("getSelectOptions", [selectLocator,])
        end


        # Gets the value of an element attribute. The value of the attribute may
        # differ across browsers (this is the case for the "style" attribute, for
        # example).
        #
        # 'attributeLocator' is an element locator followed by an @ sign and then the name of the attribute, e.g. "foo@bar"
        def get_attribute(attributeLocator)
            return get_string("getAttribute", [attributeLocator,])
        end


        # Verifies that the specified text pattern appears somewhere on the rendered page shown to the user.
        #
        # 'pattern' is a pattern to match with the text of the page
        def is_text_present(pattern)
            return get_boolean("isTextPresent", [pattern,])
        end


        # Verifies that the specified element is somewhere on the page.
        #
        # 'locator' is an element locator
        def is_element_present(locator)
            return get_boolean("isElementPresent", [locator,])
        end


        # Determines if the specified element is visible. An
        # element can be rendered invisible by setting the CSS "visibility"
        # property to "hidden", or the "display" property to "none", either for the
        # element itself or one if its ancestors.  This method will fail if
        # the element is not present.
        #
        # 'locator' is an element locator
        def is_visible(locator)
            return get_boolean("isVisible", [locator,])
        end


        # Determines whether the specified input element is editable, ie hasn't been disabled.
        # This method will fail if the specified element isn't an input element.
        #
        # 'locator' is an element locator
        def is_editable(locator)
            return get_boolean("isEditable", [locator,])
        end


        # Returns the IDs of all buttons on the page.
        # 
        # If a given button has no ID, it will appear as "" in this array.
        # 
        #
        def get_all_buttons()
            return get_string_array("getAllButtons", [])
        end


        # Returns the IDs of all links on the page.
        # 
        # If a given link has no ID, it will appear as "" in this array.
        # 
        #
        def get_all_links()
            return get_string_array("getAllLinks", [])
        end


        # Returns the IDs of all input fields on the page.
        # 
        # If a given field has no ID, it will appear as "" in this array.
        # 
        #
        def get_all_fields()
            return get_string_array("getAllFields", [])
        end


        # Returns every instance of some attribute from all known windows.
        #
        # 'attributeName' is name of an attribute on the windows
        def get_attribute_from_all_windows(attributeName)
            return get_string_array("getAttributeFromAllWindows", [attributeName,])
        end


        # deprecated - use dragAndDrop instead
        #
        # 'locator' is an element locator
        # 'movementsString' is offset in pixels from the current location to which the element should be moved, e.g., "+70,-300"
        def dragdrop(locator,movementsString)
            do_command("dragdrop", [locator,movementsString,])
        end


        # Configure the number of pixels between "mousemove" events during dragAndDrop commands (default=10).
        # Setting this value to 0 means that we'll send a "mousemove" event to every single pixel
        # in between the start location and the end location; that can be very slow, and may
        # cause some browsers to force the JavaScript to timeout.
        # If the mouse speed is greater than the distance between the two dragged objects, we'll
        # just send one "mousemove" at the start location and then one final one at the end location.
        # 
        #
        # 'pixels' is the number of pixels between "mousemove" events
        def set_mouse_speed(pixels)
            do_command("setMouseSpeed", [pixels,])
        end


        # Returns the number of pixels between "mousemove" events during dragAndDrop commands (default=10).
        #
        def get_mouse_speed()
            return get_number("getMouseSpeed", [])
        end


        # Drags an element a certain distance and then drops it
        #
        # 'locator' is an element locator
        # 'movementsString' is offset in pixels from the current location to which the element should be moved, e.g., "+70,-300"
        def drag_and_drop(locator,movementsString)
            do_command("dragAndDrop", [locator,movementsString,])
        end


        # Drags an element and drops it on another element
        #
        # 'locatorOfObjectToBeDragged' is an element to be dragged
        # 'locatorOfDragDestinationObject' is an element whose location (i.e., whose center-most pixel) will be the point where locatorOfObjectToBeDragged  is dropped
        def drag_and_drop_to_object(locatorOfObjectToBeDragged,locatorOfDragDestinationObject)
            do_command("dragAndDropToObject", [locatorOfObjectToBeDragged,locatorOfDragDestinationObject,])
        end


        # Gives focus to the currently selected window
        #
        def window_focus()
            do_command("windowFocus", [])
        end


        # Resize currently selected window to take up the entire screen
        #
        def window_maximize()
            do_command("windowMaximize", [])
        end


        # Returns the IDs of all windows that the browser knows about.
        #
        def get_all_window_ids()
            return get_string_array("getAllWindowIds", [])
        end


        # Returns the names of all windows that the browser knows about.
        #
        def get_all_window_names()
            return get_string_array("getAllWindowNames", [])
        end


        # Returns the titles of all windows that the browser knows about.
        #
        def get_all_window_titles()
            return get_string_array("getAllWindowTitles", [])
        end


        # Returns the entire HTML source between the opening and
        # closing "html" tags.
        #
        def get_html_source()
            return get_string("getHtmlSource", [])
        end


        # Moves the text cursor to the specified position in the given input element or textarea.
        # This method will fail if the specified element isn't an input element or textarea.
        #
        # 'locator' is an element locator pointing to an input element or textarea
        # 'position' is the numerical position of the cursor in the field; position should be 0 to move the position to the beginning of the field.  You can also set the cursor to -1 to move it to the end of the field.
        def set_cursor_position(locator,position)
            do_command("setCursorPosition", [locator,position,])
        end


        # Get the relative index of an element to its parent (starting from 0). The comment node and empty text node
        # will be ignored.
        #
        # 'locator' is an element locator pointing to an element
        def get_element_index(locator)
            return get_number("getElementIndex", [locator,])
        end


        # Check if these two elements have same parent and are ordered siblings in the DOM. Two same elements will
        # not be considered ordered.
        #
        # 'locator1' is an element locator pointing to the first element
        # 'locator2' is an element locator pointing to the second element
        def is_ordered(locator1,locator2)
            return get_boolean("isOrdered", [locator1,locator2,])
        end


        # Retrieves the horizontal position of an element
        #
        # 'locator' is an element locator pointing to an element OR an element itself
        def get_element_position_left(locator)
            return get_number("getElementPositionLeft", [locator,])
        end


        # Retrieves the vertical position of an element
        #
        # 'locator' is an element locator pointing to an element OR an element itself
        def get_element_position_top(locator)
            return get_number("getElementPositionTop", [locator,])
        end


        # Retrieves the width of an element
        #
        # 'locator' is an element locator pointing to an element
        def get_element_width(locator)
            return get_number("getElementWidth", [locator,])
        end


        # Retrieves the height of an element
        #
        # 'locator' is an element locator pointing to an element
        def get_element_height(locator)
            return get_number("getElementHeight", [locator,])
        end


        # Retrieves the text cursor position in the given input element or textarea; beware, this may not work perfectly on all browsers.
        # 
        # Specifically, if the cursor/selection has been cleared by JavaScript, this command will tend to
        # return the position of the last location of the cursor, even though the cursor is now gone from the page.  This is filed as SEL-243.
        # 
        # This method will fail if the specified element isn't an input element or textarea, or there is no cursor in the element.
        #
        # 'locator' is an element locator pointing to an input element or textarea
        def get_cursor_position(locator)
            return get_number("getCursorPosition", [locator,])
        end


        # Returns the specified expression.
        # 
        # This is useful because of JavaScript preprocessing.
        # It is used to generate commands like assertExpression and waitForExpression.
        # 
        #
        # 'expression' is the value to return
        def get_expression(expression)
            return get_string("getExpression", [expression,])
        end


        # Returns the number of nodes that match the specified xpath, eg. "//table" would give
        # the number of tables.
        #
        # 'xpath' is the xpath expression to evaluate. do NOT wrap this expression in a 'count()' function; we will do that for you.
        def get_xpath_count(xpath)
            return get_number("getXpathCount", [xpath,])
        end


        # Temporarily sets the "id" attribute of the specified element, so you can locate it in the future
        # using its ID rather than a slow/complicated XPath.  This ID will disappear once the page is
        # reloaded.
        #
        # 'locator' is an element locator pointing to an element
        # 'identifier' is a string to be used as the ID of the specified element
        def assign_id(locator,identifier)
            do_command("assignId", [locator,identifier,])
        end


        # Specifies whether Selenium should use the native in-browser implementation
        # of XPath (if any native version is available); if you pass "false" to
        # this function, we will always use our pure-JavaScript xpath library.
        # Using the pure-JS xpath library can improve the consistency of xpath
        # element locators between different browser vendors, but the pure-JS
        # version is much slower than the native implementations.
        #
        # 'allow' is boolean, true means we'll prefer to use native XPath; false means we'll only use JS XPath
        def allow_native_xpath(allow)
            do_command("allowNativeXpath", [allow,])
        end


        # Specifies whether Selenium will ignore xpath attributes that have no
        # value, i.e. are the empty string, when using the non-native xpath
        # evaluation engine. You'd want to do this for performance reasons in IE.
        # However, this could break certain xpaths, for example an xpath that looks
        # for an attribute whose value is NOT the empty string.
        # 
        # The hope is that such xpaths are relatively rare, but the user should
        # have the option of using them. Note that this only influences xpath
        # evaluation when using the ajaxslt engine (i.e. not "javascript-xpath").
        #
        # 'ignore' is boolean, true means we'll ignore attributes without value                        at the expense of xpath "correctness"; false means                        we'll sacrifice speed for correctness.
        def ignore_attributes_without_value(ignore)
            do_command("ignoreAttributesWithoutValue", [ignore,])
        end


        # Runs the specified JavaScript snippet repeatedly until it evaluates to "true".
        # The snippet may have multiple lines, but only the result of the last line
        # will be considered.
        # 
        # Note that, by default, the snippet will be run in the runner's test window, not in the window
        # of your application.  To get the window of your application, you can use
        # the JavaScript snippet <tt>selenium.browserbot.getCurrentWindow()</tt>, and then
        # run your JavaScript in there
        # 
        #
        # 'script' is the JavaScript snippet to run
        # 'timeout' is a timeout in milliseconds, after which this command will return with an error
        def wait_for_condition(script,timeout)
            do_command("waitForCondition", [script,timeout,])
        end


        # Specifies the amount of time that Selenium will wait for actions to complete.
        # 
        # Actions that require waiting include "open" and the "waitFor*" actions.
        # 
        # The default timeout is 30 seconds.
        #
        # 'timeout' is a timeout in milliseconds, after which the action will return with an error
        def set_timeout(timeout)
            do_command("setTimeout", [timeout,])
        end


        # Waits for a new page to load.
        # 
        # You can use this command instead of the "AndWait" suffixes, "clickAndWait", "selectAndWait", "typeAndWait" etc.
        # (which are only available in the JS API).
        # Selenium constantly keeps track of new pages loading, and sets a "newPageLoaded"
        # flag when it first notices a page load.  Running any other Selenium command after
        # turns the flag to false.  Hence, if you want to wait for a page to load, you must
        # wait immediately after a Selenium command that caused a page-load.
        # 
        #
        # 'timeout' is a timeout in milliseconds, after which this command will return with an error
        def wait_for_page_to_load(timeout)
            do_command("waitForPageToLoad", [timeout,])
        end


        # Waits for a new frame to load.
        # 
        # Selenium constantly keeps track of new pages and frames loading, 
        # and sets a "newPageLoaded" flag when it first notices a page load.
        # 
        # 
        # See waitForPageToLoad for more information.
        #
        # 'frameAddress' is FrameAddress from the server side
        # 'timeout' is a timeout in milliseconds, after which this command will return with an error
        def wait_for_frame_to_load(frameAddress,timeout)
            do_command("waitForFrameToLoad", [frameAddress,timeout,])
        end


        # Return all cookies of the current page under test.
        #
        def get_cookie()
            return get_string("getCookie", [])
        end


        # Returns the value of the cookie with the specified name, or throws an error if the cookie is not present.
        #
        # 'name' is the name of the cookie
        def get_cookie_by_name(name)
            return get_string("getCookieByName", [name,])
        end


        # Returns true if a cookie with the specified name is present, or false otherwise.
        #
        # 'name' is the name of the cookie
        def is_cookie_present(name)
            return get_boolean("isCookiePresent", [name,])
        end


        # Create a new cookie whose path and domain are same with those of current page
        # under test, unless you specified a path for this cookie explicitly.
        #
        # 'nameValuePair' is name and value of the cookie in a format "name=value"
        # 'optionsString' is options for the cookie. Currently supported options include 'path', 'max_age' and 'domain'.      the optionsString's format is "path=/path/, max_age=60, domain=.foo.com". The order of options are irrelevant, the unit      of the value of 'max_age' is second.  Note that specifying a domain that isn't a subset of the current domain will      usually fail.
        def create_cookie(nameValuePair,optionsString)
            do_command("createCookie", [nameValuePair,optionsString,])
        end


        # Delete a named cookie with specified path and domain.  Be careful; to delete a cookie, you
        # need to delete it using the exact same path and domain that were used to create the cookie.
        # If the path is wrong, or the domain is wrong, the cookie simply won't be deleted.  Also
        # note that specifying a domain that isn't a subset of the current domain will usually fail.
        # 
        # Since there's no way to discover at runtime the original path and domain of a given cookie,
        # we've added an option called 'recurse' to try all sub-domains of the current domain with
        # all paths that are a subset of the current path.  Beware; this option can be slow.  In
        # big-O notation, it operates in O(n*m) time, where n is the number of dots in the domain
        # name and m is the number of slashes in the path.
        #
        # 'name' is the name of the cookie to be deleted
        # 'optionsString' is options for the cookie. Currently supported options include 'path', 'domain'      and 'recurse.' The optionsString's format is "path=/path/, domain=.foo.com, recurse=true".      The order of options are irrelevant. Note that specifying a domain that isn't a subset of      the current domain will usually fail.
        def delete_cookie(name,optionsString)
            do_command("deleteCookie", [name,optionsString,])
        end


        # Calls deleteCookie with recurse=true on all cookies visible to the current page.
        # As noted on the documentation for deleteCookie, recurse=true can be much slower
        # than simply deleting the cookies using a known domain/path.
        #
        def delete_all_visible_cookies()
            do_command("deleteAllVisibleCookies", [])
        end


        # Sets the threshold for browser-side logging messages; log messages beneath this threshold will be discarded.
        # Valid logLevel strings are: "debug", "info", "warn", "error" or "off".
        # To see the browser logs, you need to
        # either show the log window in GUI mode, or enable browser-side logging in Selenium RC.
        #
        # 'logLevel' is one of the following: "debug", "info", "warn", "error" or "off"
        def set_browser_log_level(logLevel)
            do_command("setBrowserLogLevel", [logLevel,])
        end


        # Creates a new "script" tag in the body of the current test window, and 
        # adds the specified text into the body of the command.  Scripts run in
        # this way can often be debugged more easily than scripts executed using
        # Selenium's "getEval" command.  Beware that JS exceptions thrown in these script
        # tags aren't managed by Selenium, so you should probably wrap your script
        # in try/catch blocks if there is any chance that the script will throw
        # an exception.
        #
        # 'script' is the JavaScript snippet to run
        def run_script(script)
            do_command("runScript", [script,])
        end


        # Defines a new function for Selenium to locate elements on the page.
        # For example,
        # if you define the strategy "foo", and someone runs click("foo=blah"), we'll
        # run your function, passing you the string "blah", and click on the element 
        # that your function
        # returns, or throw an "Element not found" error if your function returns null.
        # 
        # We'll pass three arguments to your function:
        # *    locator: the string the user passed in
        # *    inWindow: the currently selected window
        # *    inDocument: the currently selected document
        # 
        # 
        # The function must return null if the element can't be found.
        #
        # 'strategyName' is the name of the strategy to define; this should use only   letters [a-zA-Z] with no spaces or other punctuation.
        # 'functionDefinition' is a string defining the body of a function in JavaScript.   For example: <tt>return inDocument.getElementById(locator);</tt>
        def add_location_strategy(strategyName,functionDefinition)
            do_command("addLocationStrategy", [strategyName,functionDefinition,])
        end


        # Saves the entire contents of the current window canvas to a PNG file.
        # Currently this only works in Mozilla and when running in chrome mode.
        # Contrast this with the captureScreenshot command, which captures the
        # contents of the OS viewport (i.e. whatever is currently being displayed
        # on the monitor), and is implemented in the RC only. Implementation
        # mostly borrowed from the Screengrab! Firefox extension. Please see
        # http://www.screengrab.org for details.
        #
        # 'filename' is the path to the file to persist the screenshot as. No                  filename extension will be appended by default.                  Directories will not be created if they do not exist,                    and an exception will be thrown, possibly by native                  code.
        def capture_entire_page_screenshot(filename)
            do_command("captureEntirePageScreenshot", [filename,])
        end


        # Writes a message to the status bar and adds a note to the browser-side
        # log.
        #
        # 'context' is the message to be sent to the browser
        def set_context(context)
            do_command("setContext", [context,])
        end


        # Sets a file input (upload) field to the file listed in fileLocator
        #
        # 'fieldLocator' is an element locator
        # 'fileLocator' is a URL pointing to the specified file. Before the file  can be set in the input field (fieldLocator), Selenium RC may need to transfer the file    to the local machine before attaching the file in a web page form. This is common in selenium  grid configurations where the RC server driving the browser is not the same  machine that started the test.   Supported Browsers: Firefox ("*chrome") only.
        def attach_file(fieldLocator,fileLocator)
            do_command("attachFile", [fieldLocator,fileLocator,])
        end


        # Captures a PNG screenshot to the specified file.
        #
        # 'filename' is the absolute path to the file to be written, e.g. "c:\blah\screenshot.png"
        def capture_screenshot(filename)
            do_command("captureScreenshot", [filename,])
        end


        # Kills the running Selenium Server and all browser sessions.  After you run this command, you will no longer be able to send
        # commands to the server; you can't remotely start the server once it has been stopped.  Normally
        # you should prefer to run the "stop" command, which terminates the current browser session, rather than 
        # shutting down the entire server.
        #
        def shut_down_selenium_server()
            do_command("shutDownSeleniumServer", [])
        end


        # Simulates a user pressing a key (without releasing it yet) by sending a native operating system keystroke.
        # This function uses the java.awt.Robot class to send a keystroke; this more accurately simulates typing
        # a key on the keyboard.  It does not honor settings from the shiftKeyDown, controlKeyDown, altKeyDown and
        # metaKeyDown commands, and does not target any particular HTML element.  To send a keystroke to a particular
        # element, focus on the element first before running this command.
        #
        # 'keycode' is an integer keycode number corresponding to a java.awt.event.KeyEvent; note that Java keycodes are NOT the same thing as JavaScript keycodes!
        def key_down_native(keycode)
            do_command("keyDownNative", [keycode,])
        end


        # Simulates a user releasing a key by sending a native operating system keystroke.
        # This function uses the java.awt.Robot class to send a keystroke; this more accurately simulates typing
        # a key on the keyboard.  It does not honor settings from the shiftKeyDown, controlKeyDown, altKeyDown and
        # metaKeyDown commands, and does not target any particular HTML element.  To send a keystroke to a particular
        # element, focus on the element first before running this command.
        #
        # 'keycode' is an integer keycode number corresponding to a java.awt.event.KeyEvent; note that Java keycodes are NOT the same thing as JavaScript keycodes!
        def key_up_native(keycode)
            do_command("keyUpNative", [keycode,])
        end


        # Simulates a user pressing and releasing a key by sending a native operating system keystroke.
        # This function uses the java.awt.Robot class to send a keystroke; this more accurately simulates typing
        # a key on the keyboard.  It does not honor settings from the shiftKeyDown, controlKeyDown, altKeyDown and
        # metaKeyDown commands, and does not target any particular HTML element.  To send a keystroke to a particular
        # element, focus on the element first before running this command.
        #
        # 'keycode' is an integer keycode number corresponding to a java.awt.event.KeyEvent; note that Java keycodes are NOT the same thing as JavaScript keycodes!
        def key_press_native(keycode)
            do_command("keyPressNative", [keycode,])
        end


    end

    SeleneseInterpreter = SeleniumDriver # for backward compatibility

end

class SeleniumCommandError < RuntimeError 
end

# Defines a mixin module that you can use to write Selenium tests
# without typing "@selenium." in front of every command.  Every
# call to a missing method will be automatically sent to the @selenium
# object.
module SeleniumHelper
    
    # Overrides standard "open" method with @selenium.open
    def open(addr)
      @selenium.open(addr)
    end
    
    # Overrides standard "type" method with @selenium.type
    def type(inputLocator, value)
      @selenium.type(inputLocator, value)
    end
    
    # Overrides standard "select" method with @selenium.select
    def select(inputLocator, optionLocator)
      @selenium.select(inputLocator, optionLocator)
    end

    # Passes all calls to missing methods to @selenium
    def method_missing(method_name, *args)
        if args.empty?
            @selenium.send(method_name)
        else
            @selenium.send(method_name, *args)
        end
    end
end
