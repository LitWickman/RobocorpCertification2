*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc
...                 Sales the order HTNML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.
Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.FileSystem
Library             RPA.RobotLogListener
Library             RPA.Robocorp.WorkItems
Library             RPA.PDF
Library             RPA.Archive
Library             RPA.Email.Exchange


*** Tasks ***
Order robots from RobotSpareBin Industries Inc

    Create Receipts Folder

    Open the robot order website
    Get Orders

    Close the annoying modal
    Fill the form

    Create ZIP Package from PDF Files

    [Teardown]    Delete Folders and Clean Up Environment




    #[Teardown]    Close Open Browser    




*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Get Orders
    Download    https://robotsparebinindustries.com    overwrite=True


Close the annoying modal
    Wait Until Element Is Visible    //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]
    Click Button    //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]

Fill the form for one order
    [Arguments]    ${Order}
    Select From List By Index    head    ${Order}[Head]
    Select Radio Button   body    ${Order}[Body]
    Input Text    xPath=/html/body/div/div/div[1]/div/div[1]/form/div[3]/input  ${Order}[Legs]
    Input Text    address   ${Order}[Address]
    Wait Until Keyword Succeeds    5x    2.0 sec     Click Order Button Successfully
    
    Screenshot     //*[@id="robot-preview-image"]     ${OUTPUT_DIR}${/}Archive/${Order}[Order number].png
    Screenshot    //*[@id="receipt"]     ${OUTPUT_DIR}${/}Archive/${Order}[Order number]${-2}.png
    Html To Pdf    //*[@id="receipt"]    ${OUTPUT_DIR}${/}Archive/${Order}[Order number].pdf
    Open Pdf       ${OUTPUT_DIR}${/}Archive/${Order}[Order number].pdf
    ${files}=    Create List    ${OUTPUT_DIR}${/}Archive/${Order}[Order number]${-2}.png    ${OUTPUT_DIR}${/}Archive/${Order}[Order number].png
    Add Files To Pdf    ${files}    ${OUTPUT_DIR}${/}Archive/${Order}[Order number].pdf
    Close Pdf    ${OUTPUT_DIR}${/}Archive/${Order}[Order number].pdf
    Move File    ${OUTPUT_DIR}${/}Archive/${Order}[Order number].pdf    ${OUTPUT_DIR}${/}Receipts/${Order}[Order number].pdf

    
    Wait Until Keyword Succeeds    5x    2.0 sec     Click Order Another
    #Store the order receipt as a PDF
    Close the annoying modal


Click Order Button Successfully
    Wait Until Element Is Visible    id:preview
    Click Button    id:preview
    Wait Until Element Is Visible    id:order
    Click Button    id:order
    Wait Until Element Is Visible    id:order-another

    
Click Order Another
    Wait Until Element Is Visible    id:order-another
    Click Button    id:order-another
  

Fill the form
    ${Orders}=    Read table from CSV    orders.csv    header=True
    FOR    ${Order}    IN    @{Orders}
        Fill the form for one order    ${Order}
    END

Create ZIP Package from PDF Files
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}/Receipts.zip
    Archive Folder With Zip    ${OUTPUT_DIR}/Receipts    ${zip_file_name}  

Close Open Browser
    Close Browser

Delete Folders and Clean Up Environment
    Remove Directory    ${OUTPUT_DIR}${/}Archive/    recursive=${True}
    Remove Directory    ${OUTPUT_DIR}${/}Receipts/    recursive=${True}
    Close Browser


Create Receipts Folder
    Create Directory    ${OUTPUT_DIR}${/}Receipts/

    
        
