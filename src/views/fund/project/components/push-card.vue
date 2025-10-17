<template>
  <div class="ele-projects-card">
    <el-card shadow="never">
      <!-- 搜索表单 -->
      <el-form
        :model="where"
        label-width="77px"
        class="ele-form-search"
        @keyup.enter.native="reload"
        @submit.native.prevent>
        <el-row :gutter="15">
          <template v-if="where.projectType === '1'">
            <el-col :lg="6" :md="12">
              <el-form-item label="患者姓名:">
                <el-input
                  clearable
                  v-model="where.patientName"
                  placeholder="请输入患者姓名"/>
              </el-form-item>
            </el-col>
            <el-col :lg="6" :md="12">
              <el-form-item label="所在地区:">
                <el-cascader
                  clearable
                  v-model="where.city"
                  class="ele-fluid"
                  placeholder="请选择省市区"
                  :options="regions.cityData"
                  popper-class="ele-pop-wrap-higher"/>
              </el-form-item>
            </el-col>
          </template>
          <template v-else>
            <el-col :lg="6" :md="12">
              <el-form-item label="组织名称:">
                <el-input
                  clearable
                  v-model="where.organizationName"
                  placeholder="请输入筹款组织名称"/>
              </el-form-item>
            </el-col>
          </template>
          <el-col :lg="6" :md="12">
            <el-form-item label="筹款金额:">
              <el-row>
                <el-col :span="11">
                  <el-input
                    clearable
                    v-model="where.targetAmount"
                    placeholder="起"/>
                </el-col>
                <el-col :span="2" style="text-align: center">至</el-col>
                <el-col :span="11">
                  <el-input
                    clearable
                    v-model="where.targetAmount"
                    placeholder="止"/>
                </el-col>
              </el-row>
            </el-form-item>
          </el-col>
          <el-col :lg="6" :md="12">
            <el-form-item label="状态:">
              <el-select
                clearable
                v-model="where.status"
                placeholder="全部"
                class="ele-fluid">
                <el-option label="未审核" :value="1"/>
                <el-option label="已通过" :value="2"/>
                <el-option label="已拒绝" :value="3"/>
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :lg="6" :md="12">
            <el-form-item label="申请日期:">
              <el-date-picker
                v-model="where.dateRange"
                type="daterange"
                range-separator="至"
                start-placeholder="开始日期"
                end-placeholder="结束日期"
                class="ele-fluid">
              </el-date-picker>
            </el-form-item>
          </el-col>
          <el-col :lg="6" :md="12">
            <div class="ele-form-actions">
              <el-button
                type="primary"
                icon="el-icon-search"
                class="ele-btn-icon"
                @click="reload">查询
              </el-button>
              <el-button @click="reset">重置</el-button>
            </div>
          </el-col>
        </el-row>
      </el-form>
      <!-- 数据表格 -->
      <ele-pro-table
        ref="table"
        :where="where"
        :datasource="url"
        :columns="columns"
        :selection.sync="selection"
        height="calc(100vh - 405px)">
        <!-- 表头工具栏 -->
        <template slot="toolbar">
          <!--          <el-button-->
          <!--            size="small"-->
          <!--            type="primary"-->
          <!--            icon="el-icon-plus"-->
          <!--            class="ele-btn-icon"-->
          <!--            @click="rowEdit(null)">新增-->
          <!--          </el-button>-->
        </template>
        <!-- 操作列 -->
        <template slot="action" slot-scope="{row}">
          <el-link
            :underline="false"
            icon="el-icon-view"
            @click="rowEdit(row, 'detail')">查看详情
          </el-link>
        </template>
        <!-- 推送状态列 -->
        <template slot="pushAction" slot-scope="{row}">
          <el-link
            :type="row.pushHome === 1 ? 'info' : 'primary'"
            :underline="true"
            @click="handlePush(row, 'pushHome')"
            v-if="where.pushType === '1'">{{ row.pushHome === 1 ? '取消推送' : '推送' }}
          </el-link>

          <el-link
            :type="row.pushDonation === 1 ? 'info' : 'primary'"
            :underline="true"
            @click="handlePush(row, 'pushDonation')"
            v-if="where.pushType === '2'">{{ row.pushDonation === 1 ? '取消推送' : '推送' }}
          </el-link>
          <!--          <el-switch-->
          <!--            v-model="row.status"-->
          <!--            @change="editStatus(row)"-->
          <!--            :active-value="1"-->
          <!--            active-text="推送"-->
          <!--            :inactive-value="2"-->
          <!--            inactive-text="不推送" />-->
        </template>
        <!-- 筹款类型列 -->
        <template slot="projectType" slot-scope="{row}">
          <el-tag
            :type="row.projectType === 1 ? '' : 'success'"
            size="mini">{{ row.projectTypeName }}
          </el-tag>
        </template>
        <!-- 筹款人信息列 -->
        <template slot="projectRaiser" slot-scope="{row}">
          <div v-if="row.projectType === 1">
            <div>{{ row.patientName }} ({{ row.patientRelation }})</div>
            <div>证件：{{ row.patientIdNo }}</div>
          </div>
          <div v-else>{{ row.organizationName }}</div>
        </template>
        <!-- 筹款信息列 -->
        <template slot="projectInfo" slot-scope="{row}">
          <div v-if="row.projectType === 1">
            <div>所患疾病：{{ row.disease }}</div>
            <div>所在地区：{{
                (row.province ? row.province : '') + (row.city ? row.city : '') + (row.district ? row.district : '')
              }}
            </div>
            <div>经济情况：{{ row.economicCondition }} {{ row.builtHouse }} {{ row.commercialHouse }}</div>
          </div>
          <div v-else>筹款周期：{{ row.startDate }} 至 {{ row.endDate }}</div>
        </template>
        <!-- 筹款金额列 -->
        <template slot="projectAmount" slot-scope="{row}">
          {{ row.raisedAmount || 0 }} / {{ row.targetAmount }}
        </template>
        <!-- 地区列 -->
        <template slot="city" slot-scope="{row}">
          {{ (row.province ? row.province : '') + (row.city ? row.city : '') + (row.district ? row.district : '') }}
        </template>
        <!-- 经济情况列 -->
        <template slot="economic" slot-scope="{row}">
          <el-tag
            v-if="row.economicCondition"
            size="mini">{{ row.economicCondition }}
          </el-tag>
          <el-tag
            v-if="row.builtHouse"
            size="mini">{{ row.builtHouse }}
          </el-tag>
          <el-tag
            v-if="row.commercialHouse"
            size="mini">{{ row.commercialHouse }}
          </el-tag>
        </template>
        <!-- 筹款周期列 -->
        <template slot="rangeDate" slot-scope="{row}">
          {{ row.startDate }} 至 {{ row.endDate }}
        </template>
        <!-- 状态列 -->
        <template slot="status" slot-scope="{row}">
          <el-tag
            :type="row.status === 1 ? 'info' : (row.status === 2 ? '' : 'danger')"
            size="mini">{{ row.statusName }}
          </el-tag>
        </template>
      </ele-pro-table>
    </el-card>
  </div>
</template>

<script>
import {mapGetters} from "vuex";
import regions from 'ele-admin/packages/regions';
import * as $util from "ele-admin/packages/util";

export default {
  name: 'CfProjectsPushCard',
  props: {
    pushType: {
      type: String,
      default: '1'
    },
  },
  computed: {
    ...mapGetters(["permission","fundList"]),
  },
  data() {
    return {
      // 省市区数据
      regions: regions,
      // 表格数据接口
      url: '/cfProjects/index',
      // 表格列配置
      columns: [{
        prop: 'id',
        label: 'ID',
        width: 60,
        align: 'center',
        showOverflowTooltip: true,
        fixed: "left"
      },
        {
          prop: 'createdAt',
          label: '申请时间',
          sortable: 'custom',
          showOverflowTooltip: true,
          minWidth: 160,
          align: 'center',
          formatter: (row, column, cellValue) => {
            return $util.toDateString(cellValue);
          }
        },
        {
          prop: 'projectTypeName',
          label: '筹款类型',
          showOverflowTooltip: true,
          minWidth: 130,
          align: 'center',
          slot: 'projectType'
        },
        {
          prop: 'contactPhone',
          label: '用户/筹款组织联系方式',
          showOverflowTooltip: true,
          minWidth: 180,
          align: 'center',
        },
        {
          prop: 'projectRaiser',
          label: '筹款人/组织',
          showOverflowTooltip: true,
          minWidth: 250,
          align: 'center',
          slot: 'projectRaiser',
        },
        {
          prop: 'projectInfo',
          label: '筹款信息',
          showOverflowTooltip: true,
          minWidth: 300,
          align: 'center',
          slot: 'projectInfo',
        },
        {
          prop: 'targetAmount',
          label: '筹款金额',
          showOverflowTooltip: true,
          minWidth: 200,
          align: 'center',
          slot: 'projectAmount',
        },
        {
          columnKey: 'action',
          label: '详情',
          width: 150,
          align: 'center',
          resizable: false,
          slot: 'action',
          fixed: "right"
        },
        {
          columnKey: 'pushAction',
          label: '推送状态',
          width: 150,
          align: 'center',
          resizable: false,
          slot: 'pushAction',
          fixed: "right"
        }
      ],
      // 表格搜索条件
      where: {
        status: 2,
        pushType: this.pushType,
        fundIds: this.$store.state.fund.fundList.length === 1 ? this.$store.state.fund.fundList.map(item => item.id).join(',') || null : null,
      },
      // 表格选中数据
      selection: [],
      // 当前编辑数据
      current: null,
    };
  },
  filters: {
    fundNameById(id, fundList) {
      // 显式传入fundList
      const fund = fundList.find((item) => item.id == id);
      return fund ? fund.name : "";
    },
  },
  mounted() {
  },
  methods: {
    /* 刷新表格 */
    reload() {
      console.log(this.where.pushType);
      this.$refs.table.reload();
    },
    /* 重置搜索 */
    reset() {
      this.where = {
        status: 2
      };
      this.reload();
    },
    /* 显示编辑 */
    rowEdit(row, type) {
      this.$emit('rowEdit', {row, type});
    },
    /* 更改状态 */
    handlePush(row, type) {
      const loading = this.$loading({lock: true});
      let params = Object.assign({
        "id": row.id,
      });
      params[type] = 1;
      this.$http.post('/cfProjects/pushStatus', params).then(res => {
        loading.close();
        if (res.data.code === 200) {
          this.$message.success(res.data.message);
          this.reload();
        }
      }).catch(e => {
        loading.close();
        this.$message.error(e.message);
      });
    },
  }
}
</script>

<style scoped>
.ele-form-search >>> .ele-fluid .el-range-input {
  width: 100%;
}
</style>
