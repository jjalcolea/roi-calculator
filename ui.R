library(shiny)

shinyUI(navbarPage("DPS: ROI Calculator",
  tabPanel("Instructions",
    h3("App purpose"),
    p("This app is a calculator used to estimate the ROI (Return in Investment) of a dropout prediction system for Higher Education Institutions.
    The calculator takes 11 input parameters, described below, and returns a textual description of the results, and a couple of graphs:"),
    tags$ul(
      tags$li("Model sensitivity vs ROI: shows how the ROI varies with respect to model sensitivity. Current sensitivity is shown as a blue dotted line."),
      tags$li("Retention effectiveness vs ROI: show how the ROI varies with respect to retention effectiveness. Current retention effectiveness is shown as a blue dotted line.")
    ),    
    h3("Input parameters"),
    tags$ul(
      tags$li("Number of enrolled students: Total number of enrolled students in the last academic year."),
      tags$li("Number of enrolled 1st time credits: Total number of credits enrolled for the 1st time in the last academic year."),
      tags$li("Number of enrolled 2nd (or more) time credits: Total number of credits enrolled for the 2nd time or later in the last academic year"),
      tags$li("Price (€) per 1s time credit: Amount that is charged to a student for a single 1st time credit."),
      tags$li("Price (€) per 2nd (or more) time credit: Amount that is charged to a student for a single 2nd time credit (or later)."),
      tags$li("Cost (€) of a single retention action: Estimated cost of the action triggered whenever a student is reported as being in risk of dropout, in order to lower the risk and retain the student"),
      tags$li("Annual cost (€) of the predictive system: Amount that is charged to the University for the use of the dropout prediction system."),
      tags$li("Dropout prevalence (%): Expected dropout rate if no actions taken (i.e. historical annual dropout)"),
      tags$li("Model sensitivity (%): Expected percentege of students who will dropout if no actions taken that are succesfully detected by the system (model parameter: should be provided by model provider)"),
      tags$li("False positive rate of the model (%): Expected percentage of students who will not dropout that are incorrectly predicted as dropouts (model parameter: should be provided by model provider)"),
      tags$li("Effectiveness of retention actions (%): Expected percentage of students who are correctly detected as dropouts and will *not* dropout due to having been subject of a retention action.")
    )    
  ),
  tabPanel("Calculator",    
    sidebarLayout(
      sidebarPanel(
        numericInput("numEst", "Number of enrolled students:", 2696),
        numericInput("credPrim", "Number of enrolled 1st time credits:", 67465),
        numericInput("credPos", "Number of enrolled 2nd (or more) time credits:", 7496),
        numericInput("precPrim", "Price (€) per 1s time credit: ", 75),
        numericInput("precPos", "Price (€) per 2nd (or more) time credit: ", 37.5),
        numericInput("costeAcc", "Cost (€) of a single retencion action:", 0),
        numericInput("costeMod", "Annual cost (€) of the predictive system:", 15000),      
        sliderInput("porcAb", "Dropout prevalence (%):", 1, 100, 30, 1),
        sliderInput("sens", "Model sensitivity (%):", 1, 100, 70, 1),
        sliderInput("porcFP", "False positive rate of the model (%):", 1, 100, 20, 1),
        sliderInput("efAcc", "Effectiveness of retention actions (%):", 1, 100, 5, 1)
      ),
    mainPanel(
      textOutput("texto1"),
      plotOutput("plot1"),
      plotOutput("plot2")
    )
  )
)))
