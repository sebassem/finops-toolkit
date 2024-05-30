---
layout: default
parent: Network
title: Application Gateways
nav_order: 0
description: 'Optimize the cost of your Application Gateways.'
permalink: /services/network/application-gateways
---

<span class="fs-9 d-block mb-4">Application Gateway</span>
Optimize the cost of your Application Gateways.
{: .fs-6 .fw-300 }

<!--
[Primary CTA](#){: .btn .btn-primary .fs-5 .mb-4 .mb-md-0 .mr-4 }
[Secondary CTA](#){: .btn .fs-5 .mb-4 .mb-md-0 .mr-4 }
-->

<details open markdown="1">
   <summary class="fs-2 text-uppercase">On this page</summary>

- [Optimize Application Gateway usage](#optimize-application-gateway-usage)
- [Storage:](#storage)
- [Virtual network and bandwidth:](#virtual-network-and-bandwidth)
- [Associated services:](#associated-services)
- [Validating VM usage:](#validating-vm-usage)
- [Quantify business value](#quantify-business-value)
- [Quantify business value](#quantify-business-value-1)
- [Understanding VM sizes (SKUs):](#understanding-vm-sizes-skus)
- [Usage patterns:](#usage-patterns)
- [Existing commitment discounts:](#existing-commitment-discounts)
- [Underlying services:](#underlying-services)
- [Manage the FinOps practice](#manage-the-finops-practice)
- [🙋‍♀️ Looking for more?](#️-looking-for-more)
- [🧰 Related tools](#-related-tools)

</details>

---

Azure Application Gateways are one of several types of [scalable and secure network services that Azure offers](https://learn.microsoft.com/azure/application-gateway/overview). Typically, you choose an application gateway when you need advanced traffic management and web application firewall capabilities for your web applications.

An Azure Application Gateway provides a dedicated instance of a web traffic load balancer with Layer 7 routing, SSL termination, and web application firewall functionality. This allows you to manage and optimize the traffic to your web applications, ensuring they are secure, fast, and reliable. However, you still need to maintain the application gateway by performing tasks such as configuring rules, updating SSL certificates, and monitoring the gateway's performance.

[About](https://azure.microsoft.com/products/application-gateway){: .btn .fs-5 .mb-4 .mb-md-0 .mr-4 }
[Pricing](https://azure.microsoft.com/pricing/details/application-gateway){: .btn .fs-5 .mb-4 .mb-md-0 .mr-4 }
[Documentation](https://learn.microsoft.com/azure/application-gateway){: .btn .fs-5 .mb-4 .mb-md-0 .mr-4 }

<br>

## Optimize Application Gateway usage

Identify Idle Application Gateway instances.This query will get the Application Gateways that have empty backend pools.

```python
resources
| where type =~ 'Microsoft.Network/applicationGateways' and resourceGroup in ({ResourceGroup})
| extend backendPoolsCount = array_length(properties.backendAddressPools),SKUName= tostring(properties.sku.name), SKUTier= tostring(properties.sku.tier),SKUCapacity=properties.sku.capacity,backendPools=properties.backendAddressPools
| project id, name, SKUName, SKUTier, SKUCapacity
| join (
    resources
    | where type =~ 'Microsoft.Network/applicationGateways' and resourceGroup in ({ResourceGroup})
    | mvexpand backendPools = properties.backendAddressPools
    | extend backendIPCount = array_length(backendPools.properties.backendIPConfigurations)
    | extend backendAddressesCount = array_length(backendPools.properties.backendAddresses)
    | extend backendPoolName  = backendPools.properties.backendAddressPools.name
    | summarize backendIPCount = sum(backendIPCount) ,backendAddressesCount=sum(backendAddressesCount) by id
) on id
| project-away id1
| where  (backendIPCount == 0 or isempty(backendIPCount)) and (backendAddressesCount==0 or isempty(backendAddressesCount))
| order by id asc
```

### Data ingestion


<!---
TODO: Include carbon emissions to the Cost Optimization advisor workbook
-->

- **VM states:** As VM instances transition through different states (running, stopped, deallocated), they may incur different billing rates. Ensure efficient VM management to minimize unnecessary costs during idle periods.

<!---
TODO: Add docs link
-->

## Storage:
<!---
TODO: Add docs link (pricing)
-->
- **Disk size:** Storage costs are determined by the size of disks attached to VMs, measured in gigabytes (GB). Larger disk sizes contribute to higher storage costs.

- **Transactions:** Transaction-based costs apply to storage and are influenced by the number of transactions per hour. Refer to the [storage billing documentation](https://docs.microsoft.com/azure/storage/blobs/storage-blobs-billing) for detailed information on transaction costs.

## Virtual network and bandwidth:
<!---
Add docs link (pricing)
-->
- **Virtual network data transfer:** Costs are associated with the amount of data transferred across virtual networks, measured in gigabytes (GB). Be mindful of data transfer volumes to optimize costs.

- **Bandwidth:** Similar to virtual network data transfer, bandwidth costs are based on the amount of data transferred. Efficient network management helps control bandwidth-related expenses.

## Associated services:
<!---
TODO: Add docs link (pricing)
-->

- **Azure Monitor:** Costs for Azure Monitor are based on the volume of data ingested. Monitor and optimize the data ingested to manage associated expenses effectively.

- **Azure Bastion:** Billing for Azure Bastion is determined by the volume of data transferred. Monitor and control data transfer to regulate costs.

- **Azure DNS:** Charges for Azure DNS depend on the number of DNS zones hosted and the quantity of DNS queries received. Manage DNS resources efficiently to control costs.

- **Load balancer:** If load balancers are utilized, costs are determined by the number of rulesets, hours used, and the amount of data processed. Optimize load balancer configurations for cost-effectiveness.

- **Backup:** Backup costs are associated with the chosen backup replication policy and frequency. Regularly assess and adjust backup strategies to align with cost-effectiveness and data recovery needs.

### Allocation

<!---
Add link to MS or F2 docs explaining the capability
-->

A highly effective method for grouping and allocating costs is through the tag inheritance feature in Cost Management. Enabled tag inheritance applies billing, resource group, and subscription tags to child resource usage records.

Once tag inheritance is enabled, tags from billing profiles, invoice sections, subscriptions, and resource groups are automatically applied to child resource usage records for the current month within 24 hours. For detailed instructions, refer to the [Cost allocation guidance](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/enable-tag-inheritance).

#### Tagging best practices:

- **Consistent tagging:** Establish a consistent tagging strategy across VMs using the [Cloud Adoption Framework (CAF) guidance](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-tagging).

Implementing tag inheritance and following these tagging best practices enhances your ability to efficiently allocate and manage VM costs.

### Reporting + analytics


<!---
TODO: Cost analysis has a feature where you can add a "cm-resource-parent" tag to your child resources (e.g., storage accounts) to link them to their logical parent and then Cost analysis will show the costs grouped together. We should inform them about this somewhere. It should be a separate doc that we reference probably in the reporting capability and possibly from here, if we end up calling out the issue.
-->


To report on VM costs comprehensively, consider all the services mentioned in the Data Ingestion capability, including but not limited to:

- **Virtual machines:** Understand the hourly billing, VM size, regional pricing, and states (running, stopped, deallocated).
- **Storage:** Factor in storage costs based on disk size and transactions per hour. 
- **Virtual network and bandwidth:** Include costs related to data transfer and bandwidth usage.
- **Associated services:** Consider costs associated with Azure Monitor, Azure Bastion, Azure DNS, and Load Balancer if used.

## Validating VM usage:

Once you've identified all the costs associated with a VM, the next crucial step is to validate the VM usage to ensure it is properly sized. This involves:

- **Right-sizing VMs:** Review the VM size to ensure it aligns with the actual workload requirements. Consider scaling up or down based on usage patterns.
- **Efficient resource management:** Leverage Azure services such as Cost Management and Azure Monitor to gain insights into VM performance metrics, allowing you to identify areas for optimization.


### Anomalies
<!---
TODO: Add link to MS or F2 doc explaining the capability
-->
Anomaly detection helps pinpoint unexpected spikes or irregularities in VM spending, enabling timely intervention to optimize costs. Identifying irregularities helps in optimizing resource allocation, ensuring resources are used efficiently.


1. **Utilize Azure Monitor:**
   - Leverage Azure Monitor to access detailed insights into VM performance metrics. Set up alerts for key metrics such as CPU usage, memory utilization, and disk activity.

2. **Cost management tools:**
   - Leverage the cost management tools, such as Azure Cost Management and Power BI, to analyze spending patterns and detect unusual spikes in VM costs.

3. **Performance metrics:**
   - Correlate cost anomalies with performance metrics. Anomalies in resource utilization may directly impact costs.

4. **Resource configuration:**
   - Evaluate the configuration of VM resources. Anomalies could be linked to improper resource allocation or sudden changes in demand.

<br>

## Quantify business value

### Unit economics

<!---
TODO: Add link to MS or F2 doc explaining the capability
-->


### Estimation + forecasting
<!---
TODO: Add link to MS or F2 doc explaining the capability
-->

Before creating a VM, leverage the [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/) to simulate costs. This tool allows you to estimate expenses based on your selected VM configurations, helping you make informed decisions and plan budgets effectively.

Understanding and proactively managing the costs associated with VMs and related services are key components of a successful cloud financial management strategy. Regularly review and optimize your resource usage to ensure cost-effectiveness and alignment with your business goals.

### Budgeting
<!---
TODO: Add link to MS or F2 doc explaining the capability
-->

Effectively budgeting for VMs in Azure involves considersing different factors, including VM sizes, usage patterns, and potential discounts.



### Benchmarking
<!---
TODO: Add link to MS or F2 doc explaining the capability
-->
<br>

## Quantify business value
<!---
TODO: Add link to MS or F2 doc explaining the capability
-->

### Architecting for cloud

<!---
TODO: Add link to MS or F2 doc explaining the capability
-->

## Understanding VM sizes (SKUs):

- **Evaluate performance needs:** Choose VM sizes based on the specific performance requirements of your workloads. Consider factors such as CPU, memory, and storage capabilities.

## Usage patterns:

- **Continuous vs. scheduled usage:**
   - Determine if VMs need to run continuously or if there are periods when they can be powered off. Schedule VMs to align with actual workload demands, optimizing costs during idle periods.

## Existing commitment discounts:

- **Reserved instances (RIs):**
   - Leverage reservations for VMs that have consistent usage patterns to benefit from significant cost savings. Commit to a one-, three-, or five-year term for VMs with ongoing, predictable usage.

- **Azure Hybrid Benefit (AHB):**
   - If you have on-premises Windows Server licenses with Software Assurance, consider utilizing Azure Hybrid Benefit for additional cost savings on VMs.

## Underlying services:

- **Networking costs:**
   - Factor in networking costs associated with data transfer and bandwidth. Optimize network configurations to minimize unnecessary expenses.

- **Backup services:**
   - Assess backup requirements for VMs. Utilize Azure Backup to efficiently manage and optimize backup costs based on retention policies and storage needs.

- **Monitoring and alerts:**
   - Leverage Azure Monitor for VMs to gain insights into performance metrics and set up alerts. Proactively monitor VMs to identify potential issues and optimize resource usage.


### Utilization efficiency
<!---
TODO: Add link to MS or F2 doc explaining the capability
-->

Optimizing the utilization efficiency of VMs in Azure is essential for achieving cost savings and maximizing resource efficiency. 


1. **Regular right-sizing reviews:**
   - Conduct regular reviews of VM sizes based on performance assessments and Azure Advisor recommendations. Right-size VMs to align with actual usage patterns.

<!---
TODO: Might also be good to call out what recommendations are available in Advisor and include some ARG queries for pulling them.
-->


2. **Scheduled shutdowns:**
   - Identify and schedule automated VM shutdowns during idle periods. Implement Azure Automation runbooks for efficient management of startup and shutdown routines.

3. **Continuous monitoring and alerts:**
   - Implement continuous monitoring using Azure Monitor and set up

4. **Automated tagging with Azure policy:**
   - Simplify and standardize tagging by utilizing Azure Policy to automatically apply tags to VMs. This streamlines the allocation process, ensuring adherence to tagging standards.

### Workload management

<!---
TODO: Add link to MS or F2 doc explaining the capability
-->

<!---
TODO: add new feature to a tool: something in the workload management section about moving VMs between regions based on regional pricing. That's probably a good opportunity for a workbook, PBI report, or AOE recommendation :-)

TODO: There's also an opportunity for us to build some tooling to recommend cm-resource-parent tags you should apply to your resources, then offering an approval workflow to apply them on your behalf.


-->


1. **Regular performance reviews:**
   - Conduct regular reviews of VM performance metrics. Adjust VM SKU based on changing workload patterns.

2. **Automation implementation:**
<!---
TODO: Move to workload management
-->

   - Implement automation for routine workload management tasks. This includes auto stop and start VMs based on schedule.

3. **Continuous monitoring:**
   - Establish a continuous monitoring process using Azure Monitor and Log Analytics. Proactively address performance issues to maintain optimal workload management.


### Licensing + SaaS

<!-- TODO: Add AHB and update based on F2 licensing guidance-->



### Commitment discounts
<!---
TODO: Add link to MS or F2 doc explaining the capability
-->

<!---
TODO: Let's get more specific and actionable. ARG queries, PBI reports, etc.
-->

Commitment discounts, such as reservations and savings plans, offer significant cost savings for organizations utilizing VMs in Azure.

1. **Evaluate workload stability:**
   - Assess VM workloads to understand stability and usage patterns. Stable workloads with predictable usage are prime candidates for Reserved Instances.

2. **Long-term commitments:**
   - If your organization can commit to long-term usage, consider Reserved Instances. Evaluate the one or three-year commitment options based on budgetary considerations.

3. **Flexibility and usage variation:**
   - For workloads with varying usage or the need for flexibility, explore Azure Savings Plans. Savings Plans provide discounts while accommodating changes in VM size, family, or region.

4. **Cost analysis:**
   - Utilize tools like Azure Pricing Calculator and Microsoft Cost Management to perform cost analysis. Compare the potential savings of commitment discounts against on-demand pricing.

5. **Regular review:**
   - Periodically review VM workloads and commitments. Adjust commitment discounts as needed to align with evolving usage patterns.


### Cloud sustainability
<!---
TODO: Add link to MS or F2 doc explaining the capability
-->

<br>

## Manage the FinOps practice
<!---
TODO: Add link to MS or F2 doc explaining the capability
-->

### FinOps practice operations
<!---
TODO: Add link to MS or F2 doc explaining the capability
-->

### FinOps education + enablement
<!---
TODO: Add link to MS or F2 doc explaining the capability
-->

### FinOps assessment
<!---
TODO: Add link to MS or F2 doc explaining the capability
-->

### Cloud policy + governance
<!---
TODO: Add link to MS or F2 doc explaining the capability
-->

### FinOps tools + services
<!---
TODO: Add link to MS or F2 doc explaining the capability
-->

### Chargeback + invoicing
<!---
TODO: Add link to MS or F2 doc explaining the capability
-->

### Intersecting disciplines
<!---
TODO: Add link to MS or F2 doc explaining the capability
-->

<br>

## 🙋‍♀️ Looking for more?

Did we miss anything? Would you like to see something added? We'd love to hear about any questions, problems, or solutions you'd like to see covered here. Create a new issue with the details that you'd like to see either included here.

[Share feedback](https://github.com/microsoft/finops-toolkit/issues/new/choose){: .btn .mt-2 .mb-4 .mb-md-0 .mr-4 }

<br>

---

## 🧰 Related tools

{% include tools.md hubs="1" pbi="1" opt="1" gov="1" ps="0" bicep="0" data="0" %}

<br>
